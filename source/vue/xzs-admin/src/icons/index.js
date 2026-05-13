import SvgIcon from '@/components/SvgIcon'

const svgFiles = import.meta.glob('./svg/*.svg', { query: '?inline', import: 'default', eager: true })
Object.keys(svgFiles).forEach(key => {
  const content = svgFiles[key]
  const name = key.replace('./svg/', '').replace('.svg', '')
  const symbol = document.createElementNS('http://www.w3.org/2000/svg', 'symbol')
  symbol.id = 'icon-' + name
  symbol.innerHTML = content
  document.body.appendChild(symbol)
})

export { SvgIcon }