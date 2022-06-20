<template>
  <div class="form">
    <a-form :form="form" :label-col="{ span: 5 }" :wrapper-col="{ span: 12 }" @submit="handleSubmit">
      <a-form-item label="IP address">
        <a-input
          v-decorator="['ip', { initialValue: ip, rules: [{ required: true, validator: validateIP }] }]"
        />
      </a-form-item>
      <a-form-item label="Netmask size">
        <a-input
          v-decorator="['netmask', { initialValue: netmask, rules: [{ required: true }] }]"
        />
      </a-form-item>
      <a-form-item label="Show hostnames">
        <a-switch v-model="scanHostnames" :disabled="loading"/>
      </a-form-item>
      <a-form-item label="Scan open ports">
        <a-switch v-model="scanOpenPorts" :disabled="loading" />
      </a-form-item>
      <div v-if="scanOpenPorts">
        <a-form-item label="Ports" style="margin-bottom:0;">
          <a-form-item :style="{ display: 'inline-block', width: 'calc(50% - 12px)' }">
            <a-input
              placeholder="Port from"
              v-decorator="['portFrom', { rules: [{ required: true, validator: validatePort }] }]"
            />
          </a-form-item>
          <span :style="{ display: 'inline-block', width: '24px', textAlign: 'center' }">
            -
          </span>
          <a-form-item :style="{ display: 'inline-block', width: 'calc(50% - 12px)' }">
            <a-input
              placeholder="Port to"
              v-decorator="['portTo', { rules: [{ validator: validatePort }] }]"
            />
          </a-form-item>
        </a-form-item>
      </div>
      <a-form-item :wrapper-col="{ span: 12, offset: 5 }">
        <a-button :type="loading ? 'danger' : 'primary'" html-type="submit">
          {{ loading ? 'Stop' : 'Scan' }}
        </a-button>
      </a-form-item>
    </a-form>
    <div v-if="networks.length !== 0" class="topology-container" ref="topology">
      <h1>{{ `${ip}/${netmask} topology` }}</h1>
      <div class="topology-unknown">
        <div v-for="(network, idx) in networks.unknown" :key="idx">
            <p><b>IP address:</b> {{ network.ipNumber }}</p>
            <p v-if="scanHostnames">{{ network.vendor }}</p>
            <p><b>MAC address:</b> {{ network.macAddress }}</p>
            <p v-if="network.ports.length !== 0" ><b>Ports:</b> {{network.ports}}</p>
            <hr>
        </div>
      </div>
      <hr>
      <div class="topology-known">
        <div v-for="(network, idx) in networks.known" :key="idx">
            <p><b>IP address:</b> {{ network.ipNumber }}</p>
            <p v-if="scanHostnames">{{ network.vendor }}</p>
            <p><b>MAC address:</b> {{ network.macAddress }}</p>
            <p v-if="network.ports.length !== 0" ><b>Ports:</b> {{network.ports}}</p>
            <hr>
        </div>
      </div>
    </div>
    <div v-if="loading" class="loader">
      <a-spin size="large"/>
      <label for="">Please wait while scan is in progress</label>
    </div>
  </div>
</template>

<script>
export default {
  data () {
    return {
      form: this.$form.createForm(this, { name: 'coordinated' }),
      ip: '192.168.10.0',
      netmask: '24',
      portFrom: '',
      portTo: '',
      loading: false,
      scanHostnames: false,
      scanOpenPorts: false,
      networks: []
    }
  },
  timers: {
    getScanResults: { time: 1000, immediate: false, repeat: true }
  },
  methods: {
    handleSubmit (e) {
      this.networks = []
      if (this.loading) {
        this.loading = false
        this.$timer.stop('getScanResults')
        this.stopScan()
        return
      }
      e.preventDefault()
      this.form.validateFields((err, values) => {
        if (err) return
        this.ip = values.ip
        this.netmask = values.netmask
        this.portFrom = values.portFrom
        this.portTo = values.portTo
        this.loading = true
        this.scanNetwork()
      })
    },
    validateIP (rule, value, message) {
      if (value == null || value === '') {
        message('Field cannot be empty!')
        return
      }
      if (this.ip4addr(value)) {
        message()
        return
      }
      message('IP address is invalid!')
    },
    validatePort (rule, value, message) {
      if (value == null || value === '') {
        message()
        return
      }
      if (value > -1 && value < 65536) {
        message()
        return
      }
      message('Port is invalid! Must be between 0 - 65535')
    },
    parseIPv4 (str) {
      if ((typeof (str) !== 'string' && !(str instanceof String)) ||
        !str.match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)) { return undefined }
      const num = []
      const parts = str.split(/\./)
      for (let i = 0; i < parts.length; i++) {
        const n = parseInt(parts[i])
        if (isNaN(n) || n > 255) { return undefined }
        num.push(n)
      }
      return num
    },
    ip4addr (value) {
      return !!this.parseIPv4(value)
    },
    scanNetwork () {
      var range = ''
      if (this.portFrom != null && this.portFrom !== '') range = this.portFrom
      if (this.portTo != null && this.portTo !== '') range = `${range}-${this.portTo}`
      this.$rpc.call('netscan', 'scan_network', { ipv4subnet: `${this.ip}/${this.netmask}`, ports: this.scanOpenPorts, range })
        .then(() => {
          this.$timer.start('getScanResults')
        })
    },
    getScanResults () {
      this.$rpc.call('netscan', 'get_results', { })
        .then(response => {
          if (response.ok) {
            try {
              this.networks = JSON.parse(response.data)
            } catch (e) {
              this.$message.error(response.data[0])
            }
            this.$timer.stop('getScanResults')
            this.loading = false
          }
        })
    },
    stopScan () {
      this.$rpc.call('netscan', 'stop_scan', { })
    }
  }
}
</script>
