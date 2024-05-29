import {createMemo,For} from "solid-js"
import {arc,interpolateSinebow,interpolateInferno} from "d3"
import {startFromFile,rawData} from "./audioSource"
const arcBuilder = arc()
tag RadialGraph
	def render
		const computed = createMemo do
			const data = rawData()
			const total = data.reduce(&, 0) do(a, v) a + v
			const highCount = data.filter do(d) d > 32.length
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
			<g transform="scale(){computed().intensity * scale + 1}">
				<For each=computed().paths>
					do(p) <path d=p.path fill=p.color>

tag App
	<self>
		<div onClick=startFromFile style="width: 100vw; height: 100vh;">
			<svg width="100%" height="100%" viewBox="-100 -100 200 200" preserveAspectRatio="xMidYMid meet">
				<RadialGraph color=interpolateSinebow scale=2.5>
				<RadialGraph color=interpolateInferno scale=1.5>
export default App
