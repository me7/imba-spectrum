import {arc,interpolateSinebow,interpolateInferno} from "d3"
# import * as icons from '/assets/*.svg'
import * as icons from '@imba/codicons'

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
		const data = rawData || []
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
		<svg width="100%" height="100%" viewBox="-100 -100 200 200" preserveAspectRatio="xMidYMid meet">
			<g transform="scale({scale + 1})">
				for p in computed().paths
					<path d=p.path fill=p.color>

def circle x
	# for i in [1,2,3]
	<circle fill='yellow' r='40' cx=x cy='0'>

tag Temp
	<self>
		<svg width="40%" height="40%" viewBox="-100 -100 200 200" preserveAspectRatio="xMidYMid meet">
				<circle fill='red' r='40' cx='10' cy='10'>
				# for i in [10,20,30] cannot use for loop inside svg tag
				circle! 10
				circle! 20
				circle! 30

tag Temp2
	<self>
		<svg[bg:red5 c:white] src=icons.ARROW_RIGHT>
		<svg[bg:blue6 c:white s:3em] src=icons.PLAY>
		<svg src=icons.BEAKER>

tag App
	<self>
		<button @click=startFromFile!> "start"
		<Temp2>

		# <RadialGraph color=interpolateSinebow scale=2.5>

imba.mount <App>
