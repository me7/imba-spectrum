tag App
	rawData

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
				imba.commit!
				global.requestAnimationFrame update
			global.requestAnimationFrame update

	<self>
		<button @click=startFromFile!> "Start From File"
		<pre> "RAW {JSON.stringify(rawData, null, 2)}"

imba.mount <App>
