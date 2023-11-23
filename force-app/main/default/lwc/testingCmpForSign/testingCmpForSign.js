import { LightningElement, api } from 'lwc';
import processSignature from '@salesforce/apex/TesingSignatureController.processSignature';



//declaration of variables for calculations
let isDownFlag,
  isDotFlag = false,
  prevX = 0,
  currX = 0,
  prevY = 0,
  currY = 0;

let x = "#0000A0";
let y = 1.5;

let canvasElement, ctx;
let attachment;
let dataURL, convertedDataURI;



export default class eSignatureCanvas extends LightningElement {
  @api recordId;
  canvas;
  isDrawing = false;
  isSignatureProvided = false;


  constructor() {
    super();
    this.template.addEventListener('mousemove', this.handleMouseMove.bind(this));
    this.template.addEventListener('mousedown', this.handleMouseDown.bind(this));
    this.template.addEventListener('mouseup', this.handleMouseUp.bind(this));
    this.template.addEventListener('mouseout', this.handleMouseOut.bind(this));
  }


  renderedCallback() {
    if (this.canvas) {
      return;
    }
    canvasElement = this.template.querySelector('canvas');
    ctx = canvasElement.getContext('2d');

    }
    spinner = false;
  handleSave() {
    this.spinner = true;

    ctx.globalCompositeOperation = "destination-over";
    ctx.fillStyle = "rgba(0, 0, 0, 0)";//"#FFF"; //white
    ctx.fillRect(0, 0, canvasElement.width, canvasElement.height);

    const base64Signature = canvasElement.toDataURL();

    processSignature({ base64Signature })
      .then(result => {
        console.log('Signature processed successfully.');
        this.isSignatureProvided = true;
        this.dispatchSignatureProvidedEvent();
        window.location.reload();
      })
      .catch(error => {
        console.error('Error processing signature:', error);
      });
  }

  dispatchSignatureProvidedEvent() {
    this.spinner = false;
    this.dispatchEvent(new CustomEvent('increasecount', {
      detail: {
        message: this.isSignatureProvided
      }
    }));

  }
  handleClearClick() {
    ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);
    this.isSignatureProvided = false;
  }

  handleMouseDown(event) {
    this.isDrawing = true;
    this.searchCoordinatesForEvent('down', event);

  }

  handleMouseMove(event) {
    if (this.isDrawing) {
      this.searchCoordinatesForEvent('move', event);
    }
  }

  handleMouseUp() {
    this.isDrawing = false;
    this.searchCoordinatesForEvent('up', event);

  }

  handleMouseOut() {
    this.isDrawing = false;
    this.searchCoordinatesForEvent('out', event);

  }

  get isSaveDisabled() {
    return !this.isSignatureProvided;
  }

  searchCoordinatesForEvent(requestedEvent, event) {
    event.preventDefault();
    if (requestedEvent === 'down') {
      this.setupCoordinate(event);
      isDownFlag = true;
      isDotFlag = true;
      if (isDotFlag) {
        this.drawDot();
        isDotFlag = false;
      }
    }
    if (requestedEvent === 'up' || requestedEvent === "out") {
      isDownFlag = false;
    }
    if (requestedEvent === 'move') {
      if (isDownFlag) {
        this.setupCoordinate(event);
        this.redraw();
      }
    }
  }

  setupCoordinate(eventParam) {
    const clientRect = canvasElement.getBoundingClientRect();
    prevX = currX;
    prevY = currY;
    currX = eventParam.clientX - clientRect.left;
    currY = eventParam.clientY - clientRect.top;
  }

  redraw() {
    ctx.beginPath();
    ctx.moveTo(prevX, prevY);
    ctx.lineTo(currX, currY);
    ctx.strokeStyle = x; //sets the color, gradient and pattern of stroke
    ctx.lineWidth = y;
    ctx.closePath(); //create a path from current point to starting point
    ctx.stroke(); //draws the path
  }

  //this draws the dot
  drawDot() {
    ctx.beginPath();
    ctx.fillStyle = x; //blue color
    ctx.fillRect(currX, currY, y, y); //fill rectrangle with coordinates
    ctx.closePath();
  }

}