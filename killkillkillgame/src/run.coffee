$ ->
  backgroundX = 0
  backgroundWidth = 240

  Bullet = (x, y, direction) ->
    this.x = x
    this.y = y
    this.width = 6
    this.height = 6
    this.direction = direction
    this.speed = 15

    this.draw = ->
      image = images['bullets']
      console.log(this.x)
      console.log(this.y)

      context.drawImage(image, 265, 487, this.width, this.height, this.x, 480 - this.y - this.height, this.width, this.height)

    this.update = ->
      if this.direction == 'left'
        this.x -= this.speed
      else if this.direction == 'right'
        this.x += this.speed

      if this.x + this.width < 0 || this.x > canvas.width()
        console.log('deletin')
        hero.bullets = _(hero.bullets).without(this)

    return this

  baddie =
    self: baddie
    x: 800
    y: 30
    speed: 3
    velocity: 0
    state: 'leftStand'
    drawState: 'rightStand'

    states:
      leftStand: [82, 16, 28, 38]
      rightStand: [146, 16, 28, 38]

    update: ->
      if counter % 200 < 100
        baddie.turnLeft()
      else
        baddie.turnRight()

    turnLeft: ->
      baddie.drawState = baddie.state = 'leftStand'

    turnRight: ->
      baddie.drawState = baddie.state = 'rightStand'

    draw: ->
      image = images['baddies']
      state = baddie.states[baddie.drawState]

      width = state[2]
      height = state[3]
      context.drawImage(image, state[0], state[1], width, height, baddie.x, 480 - baddie.y - height, width, height)

  hero =
    self: hero
    x: 50
    y: 30
    speed: 4
    velocity: 0
    state: 'rightStand'
    drawState: 'rightStand'
    shooting: false
    shootSpeed: 6
    shootCounter: 0
    animLoop: []
    bullets: []

    states:
      leftStand: [82, 16, 28, 38]
      rightStand: [146, 16, 28, 38]
      leftRun1: [21, 134, 20, 36]
      leftRun2: [43, 134, 20, 38]
      leftRun3: [70, 140, 20, 30]
      leftRun4: [95, 135, 18, 36]
      leftRun5: [116, 135, 19, 36]
      rightRun1: [241, 134, 20, 36]
      rightRun2: [217, 134, 20, 38]
      rightRun3: [190, 140, 20, 30]
      rightRun4: [169, 135, 18, 36]
      rightRun5: [145, 135, 18, 36]

    leftRunLoop:
      ['leftRun1', 'leftRun2', 'leftRun3', 'leftRun4', 'leftRun5', 'leftRun3']

    rightRunLoop:
      ['rightRun1', 'rightRun2', 'rightRun3', 'rightRun4', 'rightRun5', 'rightRun3']

    width: ->
      hero.states[hero.drawState][2]

    update: ->
      hero.x += hero.velocity
      if hero.x < 0
        hero.x = 0

      if hero.x + hero.width() > canvas.width()
        hero.x = canvas.width() - hero.width()

      if hero.velocity > 0 && hero.x + hero.width() / 2 > 320 && hero.x + hero.width() / 2 + backgroundX < 640
        hero.x -= hero.velocity
        backgroundX += hero.velocity
        baddie.x -= hero.velocity

      if hero.velocity < 0 && hero.x - hero.width() / 2 < 320 && backgroundX > 0
        hero.x -= hero.velocity
        backgroundX += hero.velocity
        baddie.x -= hero.velocity

      backgroundX = 0 if backgroundX < 0
      backgroundX = 320 if backgroundX > 320


      if (counter % 5) == 0
        hero.nextState()

      if hero.shooting
        if hero.shootCounter % hero.shootSpeed == 0
          offset = 22
          if hero.state == 'leftRun' || hero.state == 'leftStand'
            hero.bullets.push(new Bullet(hero.x - 4, hero.y + offset, 'left'))
          else if hero.state == 'rightRun' || hero.state == 'rightStand'
            hero.bullets.push(new Bullet(hero.x + hero.width(), hero.y + offset, 'right'))
      hero.shootCounter++

      _(hero.bullets).each (bullet) ->
        bullet.update()
        bullet.draw()

    startLeft: ->
      if hero.state != 'leftRun'
        hero.state = 'leftRun'
        hero.drawState = 'leftRun1'
        hero.animLoop = hero.leftRunLoop
        hero.velocity = -1 * hero.speed

    stopLeft: ->
      if hero.state == 'leftRun'
        hero.animLoop = []
        hero.velocity = 0
        hero.drawState = 'leftStand'
        hero.state = 'leftStand'

    startRight: ->
      if hero.state != 'rightRun'
        hero.state = 'rightRun'
        hero.drawState = 'rightRun1'
        hero.animLoop = hero.rightRunLoop
        hero.velocity = hero.speed

    stopRight: ->
      if hero.state == 'rightRun'
        hero.animLoop = []
        hero.velocity = 0
        hero.drawState = 'rightStand'
        hero.state = 'rightStand'

    shoot: ->
      hero.shooting = true

    stopShooting: ->
      hero.shooting = false

    draw: ->
      image = images['hero']
      state = hero.states[hero.drawState]

      width = state[2]
      height = state[3]
      context.drawImage(image, state[0], state[1], width, height, hero.x, 480 - hero.y - height, width, height)

    runLeft: ->
      hero.x -= hero.speed

    runRight: ->
      hero.animLoop = hero.rightRunLoop
      hero.x += hero.speed

      if (hero.x % 5) == 0
        hero.nextState()

    nextState: ->
      animLoop = hero.animLoop
      if !_(animLoop).isEmpty()
        index = _(animLoop).indexOf(hero.drawState)

        if index == -1
          hero.drawState = animLoop[0]
        else
          hero.drawState = animLoop[(index + 1) % animLoop.length]


  clearScreen = ->
    context.clearRect(0, 0, canvas.width(), canvas.height());


  drawBackground = ->
    image = images['bg']
    context.drawImage(image, backgroundX, backgroundWidth, 320, 240, 0, 0, 640, 480)

  # loading images
  imgSrcs =
    hero: 'img/ContraSheet1.gif'
    bg: 'img/bg.png'
    bullets: 'img/ContraSheet8.gif'
    baddies: 'img/ContraSheet2.gif'

  images = {}

  loadedImages = 0
  numImages = 0

  for name, src of imgSrcs
    numImages++

  for name, src of imgSrcs
    images[name] = new Image()
    images[name].onload = ->
      if ++loadedImages >= numImages
        startScreen()
    images[name].src = src

  # audio
  soundtrack = new Audio("audio/contra-bases.mp3");


  canvas = $('#killkillkill')
  context = window.context = canvas[0].getContext('2d');

  keyState = undefined

  $('body').keydown (e) ->
    if game
      if e.keyCode == 37
        hero.startLeft()
      else if e.keyCode == 39
        hero.startRight()
      else if e.keyCode == 32
        hero.shoot()

  $('body').keyup (e) ->
    if game
      if e.keyCode == 37
        hero.stopLeft()
      else if e.keyCode == 39
        hero.stopRight()
      else if e.keyCode = 32
        hero.stopShooting()

  clearBlack = ->
    context.fillStyle = 'black'
    context.rect(0, 0, canvas.width(), canvas.height());
    context.fill()

  writeText = (text, x, y, color) ->
    color = 'white' if !color
    context.font = '40pt Courier New'
    context.fillStyle = color
    context.fillText(text, x, y)

  start = true
  game = false

  startScreen = ->
    started = false

    firstScreen = ->
      clearBlack()
      writeText('Hit Space to Start', 30, 250)
      if !started
        window.webkitRequestAnimationFrame ->
          firstScreen()
      else
        hello()

    hello = ->
      clearBlack()
      writeText('Hello!', 50, 80)
      setTimeout(welcome, 2000)

    welcome = ->
      writeText('KILLKILLKILL!!!', 50, 150)
      setTimeout(enterPhone, 2000)

    complete = false
    digits = []

    $('body').keydown (e) ->
      if e.keyCode == 32
        started = true
      if e.keyCode > 47 && e.keyCode < 58 && digits.length < 11
        digits.push(e.keyCode - 48)
      else if e.keyCode == 8
        digits.pop()
      else if e.keyCode == 13 && digits.length == 10
        console.log('yo?')
        complete = true

    enterPhone = ->
      clearBlack()
      writeText('Please enter your', 50, 80)
      writeText('phone # and hit', 50, 140)
      writeText('Enter:', 50, 200)

      if (digits.length > 0)
        stringVal = ""
        firstThree = digits.slice(0,3)
        secondThree = digits.slice(3,6)
        lastFour = digits.slice(6, 10)

        if firstThree.length > 0
          stringVal = "("
          stringVal += firstThree.join("")
          if firstThree.length == 3
            stringVal += ") "

        if secondThree.length > 0
          stringVal += secondThree.join("")

        if lastFour.length > 0
          stringVal += "-"
          stringVal += lastFour.join("")

        writeText(stringVal, 40, 300)

      if !complete
        window.webkitRequestAnimationFrame ->
          enterPhone()
      else
        thanks()

    thanks = ->
      clearBlack()
      writeText('Thanks!', 50, 80)
      setTimeout(finish, 2000)

    finish = ->
      console.log("????")
      writeText('KILLKILLKILL!!!!!!!', 50, 140, 'red')
      writeText('KILLKILLKILL!!!!!!!', 50, 200, 'red')
      writeText('KILLKILLKILL!!!!!!!', 50, 260, 'red')
      writeText('KILLKILLKILL!!!!!!!', 50, 320, 'red')
      writeText('KILLKILLKILL!!!!!!!', 50, 380, 'red')
      writeText('KILLKILLKILL!!!!!!!', 50, 440, 'red')
      writeText('KILLKILLKILL!!!!!!!', 50, 500, 'red')
      setTimeout(startAnimation, 2000)

    firstScreen()

  sendPhoneNumber = ->
    number = digits.join('')
    digits = undefined
    $.ajax
      url: 'http://localhost:3000/phone_numbers'
      data:
        number: number
      type: 'post'

  startAnimation = ->
    game = true
    start = false
    #soundtrack.play()
    animate()

  counter = 0
  speed = 1

  animate = ->
    # slowdown
    counter += 1

    if (counter % speed) == 0
      # clear
      clearScreen()
      drawBackground()

      hero.update()
      baddie.update()

      hero.draw()
      baddie.draw()

    if (counter < 150)
      context.font = 'bold 16pt Courier New'
      context.fillStyle = 'white'
      context.fillText('Bobby Brasher, 19, sent here to find...', 30, 30)
      context.fillText('and kill', 60, 60)
      context.fillText('The Enemy...', 90, 90)

    # loop
    window.webkitRequestAnimationFrame ->
      animate();
