import honk from '/assets/honk.mp3'

tag App
	count = 0
	<self>
		<audio controls src=honk>
		"count is {count}"

imba.mount <App>
