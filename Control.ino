#define PIN_1 2
#define PIN_2 4
#define PIN_3 7

void setup() {
  pinMode(PIN_1, OUTPUT);
  pinMode(PIN_2, OUTPUT);
  pinMode(PIN_3, OUTPUT);

  Serial.begin(9600);

  digitalWrite(PIN_1, HIGH);
  digitalWrite(PIN_2, HIGH);
  digitalWrite(PIN_3, LOW);
}

void loop() {
  if (Serial.available() > 0) {
    char receivedChar = Serial.read();
    if (receivedChar == 'w') {
      digitalWrite(PIN_1, LOW);
      digitalWrite(PIN_3, HIGH);
      delay(200);
      digitalWrite(PIN_1, HIGH);
    }
    else if (receivedChar == 'l') {
      digitalWrite(PIN_3, LOW);
    }
  }
}
