'use strict';
angular.module('subgamesApp').directive('netAnim', function($interval) {
  return {
    templateUrl: 'components/net-anim/net-anim.html',
    restrict: 'EA',
    link: function(scope, element, attrs) {
      var viewWidth = 350,
      viewHeight = 350,
      drawingCanvas = element.find("canvas")[0],
      ctx,
      transInt,
      timeStep = (1/60),
      nodeCount = 150,
      time = 0;

      var nodes = [],
      signals = [];

      var signalCount = 0;

      function cleanup(){
        $interval.cancel(transInt);
      }

      function setup(){
        initDrawingCanvas();
        createNodes();
        connectNodes();

        transmit();

        //todo: clear this later
        transInt = $interval(transmit, 1500);

        requestAnimationFrame(loop);
      }

      function initDrawingCanvas() {
        drawingCanvas.width = viewWidth;
        drawingCanvas.height = viewHeight;
        ctx = drawingCanvas.getContext('2d');
      }

      function createNodes() {
        var rad = viewWidth * 0.5 - 10;

        for (var i = 0; i < nodeCount; i++) {
          var q = Math.random() * (Math.PI * 2);
          var r = Math.sqrt(Math.random());
          var x = (rad * r) * Math.cos(q) + viewWidth * 0.5;
          var y = (rad * r) * Math.sin(q) + viewWidth * 0.5;

          nodes[i] = new Node(x, y);
        }
      }

      function connectNodes() {
        var connection,
        j,
        connectCount;

        for (var i = 0; i < nodes.length; i++) {
          j = 0;

          connectCount = Math.floor(randomRange(3, 6));

          while (j < connectCount) {
            connection = getRandom(nodes);

            if (nodes[i] !== connection) {
              nodes[i].connections.push(connection);
              j++;
            }
          }
        }
      }

      function transmit() {
        if(window.vis()){
          signals.push(new Signal(getRandom(nodes)));
          signalCount++;
        }
      }

      function update() {
        nodes.forEach(function(n) {
          n.update();
        });

        signals.forEach(function(s) {
          if (s.update() === true) {
            signals.splice(signals.indexOf(s), 1);
          }
        });
      }

      function draw() {
        ctx.clearRect(0, 0, viewWidth, viewHeight);

        nodes.forEach(function(n) {
          n.draw();
        });

        signals.forEach(function(s) {
          s.draw();
        });
      }

      function loop() {
        update();
        draw();
        time += timeStep;
        requestAnimationFrame(loop);
      }

      function Node(x, y) {
        this.x = this._x = x;
        this.y = this._y = y;

        this.connections = [];

        this.r = randomRange(-10, 10);
      }

      Node.prototype = {
        update:function() {
          this.x = this._x + Math.sin(time) * this.r;
          this.y = this._y + Math.cos(time) * this.r;
        },
        draw:function() {
          //ctx.strokeStyle = '#fff';
          //ctx.fillStyle = '#fff';
          ctx.strokeStyle = '#000';
          ctx.fillStyle = '#000';
          ctx.lineWidth = 0.1;

          ctx.fillRect(this.x, this.y, 1, 1);

          for (var i = 0; i < this.connections.length; i++) {
            ctx.beginPath();
            ctx.moveTo(this.x, this.y);
            ctx.lineTo(this.connections[i].x, this.connections[i].y);
            ctx.stroke();
          }
        }
      };

      function Signal(start) {
        this.start = start;
        this.parts = [];
        this.completeParts = [];
        this.strength = 4.0;
        this.jumps = 0;

        var tint = (signalCount % 12) * 30;
        this.style = 'hsl(' + tint + ',100%,50%)';

        for (var i = 0; i < start.connections.length; i++) {
          this.parts.push(new SignalPart(this.start, this.start.connections[i], this.strength, this.style));
        }
      }
      Signal.prototype = {
        update:function() {
          var complete = false;
          this.completeParts.length = 0;

          for (var i = this.parts.length - 1; i >= 0; i--) {
            this.parts[i].time += timeStep;

            if (this.parts[i].complete) {
              this.completeParts.push(this.parts.splice(i, 1)[0]);
            }
          }

          if (this.completeParts.length > 0) {
            this.jumps++;
            this.strength--;
            complete = this.jumps === 3;
          }

          if (complete === false) {
            var part,
            end,
            connection;

            for (var j = 0; j < this.completeParts.length; j++) {
              part = this.completeParts[j];
              end = part.end;

              for (var k = 0; k < end.connections.length; k++) {
                connection = end.connections[k];

                this.parts.push(new SignalPart(end, connection, this.strength, this.style));
              }
            }
          }

          return complete;
        },
        draw:function() {
          for (var i = 0; i < this.parts.length; i++) {
            this.parts[i].draw();
          }
        }
      };

      function SignalPart(start, end, strength, style) {
        this.start = start;
        this.end = end;
        this.strength = strength;
        this.style = style;
        this._time = 0;
        this.prevTime = 0;
        this.duration = 2;
        this.complete = false;

        this.p0 = {x:0, y:0};
        this.p1 = {x:0, y:0};
      }
      SignalPart.prototype = {
        set time(v) {
          this.prevTime = this._time;
          this._time = v >= this.duration ? this.duration : v;
          this.complete = this._time === this.duration;
        },
        get time() {
          return this._time;
        },
        draw:function() {
          var t0 = Ease.outCubic(this.prevTime, 0, 1, this.duration);
          var t1 = Ease.outQuad(this.time, 0, 1, this.duration);
          lerp(this.start, this.end, t0, this.p0);
          lerp(this.start, this.end, t1, this.p1);

          ctx.strokeStyle = this.style;
          ctx.lineWidth = this.strength * 0.25;
          ctx.lineCap = 'round';
          ctx.beginPath();
          ctx.moveTo(this.p0.x, this.p0.y);
          ctx.lineTo(this.p1.x, this.p1.y);
          ctx.stroke();
        }
      };



      function randomRange(min, max) {
        return min + Math.random() * (max - min);
      }

      function getRandom(a) {
        return a[Math.floor(Math.random() * a.length)];
      }

      function lerp(n1, n2, t, p) {
        p = p || {x:0, y:0};

        p.x = n1.x + t * (n2.x - n1.x);
        p.y = n1.y + t * (n2.y - n1.y);

        return p;
      }

      /**
       * easing equations from http://gizma.com/easing/
       * t = current time
       * b = start value
       * c = delta value
       * d = duration
       */
      var Ease = {
        inCubic:function (t, b, c, d) {
          t /= d;
          return c*t*t*t + b;
        },
        outCubic:function(t, b, c, d) {
          t /= d;
          t--;
          return c*(t*t*t + 1) + b;
        },
        inQuad: function (t, b, c, d) {
          return c*(t/=d)*t + b;
        },
        outQuad: function (t, b, c, d) {
          return -c *(t/=d)*(t-2) + b;
        },
        inOutCubic:function(t, b, c, d) {
          t /= d/2;
          if (t < 1) return c/2*t*t*t + b;
          t -= 2;
          return c/2*(t*t*t + 2) + b;
        }
      };
      setup();
      scope.$on('$destroy', function() {
        console.log("Network animation destroyed.");
        cleanup();

      });
    }
  };
});
