import {arc,interpolateSinebow,interpolateInferno} from "d3"
const arcBuilder = arc()

let rawData

def startFromFile
		const res = await global.fetch('/assets/inp.mp3')
		const byteArray = await res.arrayBuffer()
		const context = new AudioContext()
		const audioBuffer = await context.decodeAudioData(byteArray)
		const source = context.createBufferSource()
		source.buffer = audioBuffer
		const analyser = context.createAnalyser()
		analyser.fftSize = 512
		source.connect analyser
		analyser.connect(context.destination)
		source.start()
		const bufferLength = analyser.frequencyBinCount
		const dataArray = new Uint8Array(bufferLength)
		const update = do
			analyser.getByteFrequencyData dataArray
			const orig = Array.from(dataArray)
			rawData = [[...orig].reverse(), orig].flat()
			# imba.commit!
			global.requestAnimationFrame update
		global.requestAnimationFrame update

tag RadialGraph
	color
	scale
	def computed
		const data = rawData
		const total = data.reduce(&, 0) do(a, v) a + v
		const highCount = data.filter(do(d) d > 32).length
		const intensity = highCount / data.length
		const paths = []
		const range = 1 + intensity
		const rangeInRadians = range * Math.PI
		const startAngle = -rangeInRadians / 2
		let currentAngle = startAngle
		for d in data
			const angle = rangeInRadians * d / total
			const path = arcBuilder
				innerRadius: 50 - d + 10 / 255 * 35
				outerRadius: 50 + d + 10 / 255 * 35
				startAngle: currentAngle
				endAngle: currentAngle + angle
			paths.push
				path: path
				color: color(d / 255)
			currentAngle += angle
		return
			paths: paths
			intensity: intensity

	<self>
		<g>
			for p in computed().paths
				<path d=p.path fill=p.color>

tag Circle
	<self>
		<circle cx='0' cy='0' r='50' fill='yellow'>

tag App
	<self>
		<div @click=startFromFile! style="width: 100vw; height: 100vh;">
			<svg width="100%" height="100%" viewBox="-100 -100 200 200" preserveAspectRatio="xMidYMid meet">
				# <Circle> tag will not work here
				<circle cx='0' cy='0' r='50' fill='red'>
				# <RadialGraph color=interpolateSinebow scale=2.5>
				# <RadialGraph color=interpolateInferno scale=1.5>
		# <pre> "RAW {JSON.stringify(rawData, null, 2)}"

imba.mount <App>
