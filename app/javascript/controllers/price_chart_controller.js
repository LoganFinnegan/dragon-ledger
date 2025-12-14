import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { itemId: Number, series: String }
  static targets = ["canvas", "from", "to", "fillGaps"]

  connect() {
    this.chart = null
    this.setDefaultDates()
    this.render()
  }

  disconnect() {
    if (this.chart) this.chart.destroy()
  }

  setDefaultDates() {
    const today = new Date()
    const to = today.toISOString().slice(0, 10)

    const fromDate = new Date(today)
    fromDate.setDate(fromDate.getDate() - 30)
    const from = fromDate.toISOString().slice(0, 10)

    if (!this.fromTarget.value) this.fromTarget.value = from
    if (!this.toTarget.value) this.toTarget.value = to
  }

  async submit(event) {
    event.preventDefault()
    await this.render()
  }

  async render() {
    const from = this.fromTarget.value
    const to = this.toTarget.value
    const fillGaps = this.fillGapsTarget.checked ? "true" : "false"

    const url = `/api/items/${this.itemIdValue}/price_snapshots?series=${encodeURIComponent(this.seriesValue)}&from=${from}&to=${to}&fill_gaps=${fillGaps}`

    const resp = await fetch(url)
    if (!resp.ok) throw new Error(`API error: ${resp.status}`)
    const points = await resp.json()

    const labels = points.map(p => p.sampled_at.slice(0, 10))
    const values = points.map(p => p.price)
    const filled = points.map(p => !!p.filled)

    // same size for all points
    const pointRadius = filled.map(() => 4)
    const pointHoverRadius = filled.map(() => 6)

    // real points = solid green
    // filled points = solid red
    const pointBackgroundColor = filled.map(isFilled => (isFilled ? "red" : "green"))
    const pointBorderColor = filled.map(isFilled => (isFilled ? "red" : "green"))
    const pointBorderWidth = filled.map(() => 1)

    if (this.chart) this.chart.destroy()

    const ctx = this.canvasTarget.getContext("2d")
    this.chart = new window.Chart(ctx, {
      type: "line",
      data: {
        labels,
        datasets: [{
          label: `${this.seriesValue} price`,
          data: values,
          pointRadius,
          pointHoverRadius,
          pointBackgroundColor,
          pointBorderColor,
          pointBorderWidth,
          tension: 0.15,
          segment: {
            borderDash: seg => {
              const a = seg.p0DataIndex
              const b = seg.p1DataIndex
              return (filled[a] || filled[b]) ? [6, 6] : undefined
            }
          }
        }]
      }
    })
  }
}
