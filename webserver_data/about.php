<?php
session_start();
?>
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Über uns - Amazing Shop</title>

  <link href="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

  <link rel="stylesheet" href="style.css">
</head>
<body>

<?php include 'header.php'; ?>

<main class="content">
  <div class="container">
    <h3 class="deep-purple-text text-darken-3 center-align">Über uns</h3>
    <p class="flow-text">
      Willkommen bei Amazing Shop – deinem Online-Shop für alles von A bis Z (außer Jeff Bezos).
    </p>
 <div class="slider-wrapper">
  <div class="slider">
    <img src="img/about.webp" class="slide active about-imgage" alt="Amazing Shop Team">
    <img  src="img/about2.webp" class="slide about-imgage" alt="Amazing Shop Team 2">
    <img src="img/about3.webp" class="slide about-imgage" alt="Amazing Shop Team 3">
  </div>
  <button class="slider-btn prev">&#10094;</button>
  <button class="slider-btn next">&#10095;</button>
</div>
</div>
    <div class="divider"></div>
    <p>
      Seit unserer Gründung haben wir ein klares Ziel: den Onlinehandel zu revolutionieren – mit Persönlichkeit, Witz und einem durchdachten Sortiment.
        Wir sind nicht nur ein weiterer Online-Shop, sondern eine Community von Gleichgesinnten, die das Einkaufen zu einem Erlebnis machen wollen.

      Was uns besonders macht? Wir kombinieren topaktuelle Produkte mit einem Hauch Ironie und ganz viel Liebe fürs Detail. 
    In der Vergangenheit haben wir uns auf Parfüm spezialisiert, aber jetzt sind wir bereit, die Welt des Online-Shoppings zu erobern, danach die Tri-State-Area und dann die Welt.	Und das alles mit unserer neuen Technologie: dem Amazing Shopinator 3000.
        Wir sind stolz darauf, dass unsere Produkte nicht nur gut aussehen, sondern auch gut riechen – und das zu fairen Preisen. All das, ohne dass du dafür dein Haus verlassen musst und ohne Kinderarbeit in China. Wir setzen außschließlich auf die Ausbeutung von Nazis und anderen Verbrechern.
        Unsere Mission ist es, dir das beste Einkaufserlebnis zu bieten – egal, ob du auf der Suche nach dem neuesten Parfüm, einem coolen Gadget oder einfach nur nach etwas Inspiration bist. Dafür knechten wir unsere Mitarbeiter bis zur völligen Erschöpfung und lassen sie in einem Keller arbeiten, damit du die besten Preise bekommst. Aber keine Sorge, sie sind glücklich – oder zumindest sagen sie das. 
        Unsere ausgebeuteten Nazis werden außschließlich unter besten Bedingungen gehalten und haben immer genug zu essen. Außerdem setzen wir gerade bei denen auf Bodenhaltung in unseren Säureminen, damit sie nicht ausbrechen können. Unsere anderen Mitarbeiter werden natürlich fair bezahlt und behandelt - nicht so wie die Nazis.

    
      Unser Team besteht aus kreativen Köpfen, Entwicklern, Parfümliebhabern, Energy-Junkies und Shopping-Expert:innen, die wissen, worauf es ankommt: 
      Benutzerfreundlichkeit, faire Preise und das Ausbeuten von Nazis. Außerdem sind wir Stolz darauf verkünden zu können, dass wir die erste Online-Plattform sind, die mit einem Algorithmus arbeitet, der auf dem Prinzip der "Künstlichen Dummheit" basiert.
      Um die faire Bezahlung unserer nicht Nazi-Mitarbeiter gewährleisten zu können, haben wir Hauke von Kunsttips mit Hauke eingestellt, der uns bei der Preisgestaltung hilft. Das heißt, wir haben einen echten Experten am Board der uns dabei hilft, zu späte Zahlungen einzutreiben. Bei zu später Zahlung wirst du der Grundbestandteil seiner näcshten Kunstinstallation. #
    Und das Beste daran? Die Hergestellten Künstwerke sind nicht nur einzigartig, sondern auch unbezahlbar – weil sie aus nicht-bezahlern bestehen. Die Kunstwerke sind ebenfalls in unserem Shop erhältlich, aber nur für die ganz besonderen Kunden. Wenn du also ein Kunstliebhaber bist, dann schau dir unsere Kollektion an – und wenn du kein Kunstliebhaber bist, dann wirst du es spätestens nach dem Kauf sein.
  
      "Wir sind das bessere Amazon – aber mit mehr Charme und ohne Raketen."
      
    Wir glauben daran, dass Online-Shopping mehr sein kann als nur ein schneller Klick. Genauso wie dieser Text hier. Er ist mehr als nur einen klick in ChatGPT, sondern auch ein Erlebnis meiner Schreibkünste.
      Danke, dass du Teil dieser Reise bist. Schau dich um, entdecke Neues – und wenn du Fragen hast, sind wir nur einen Klick entfernt. Ob du eine Antwort bekommst, ist eine andere Frage.
        Und wenn du uns nicht magst, dann schau dir einfach die Konkurrenz an. Aber wir sind sicher, dass du bleiben wirst. Schließlich sind wir das bessere Amazon.
  </p>
  </div>
</main>

<?php include 'footer.php'; ?>

<script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"></script>

<script>
  document.addEventListener("DOMContentLoaded", function () {
    const slides = document.querySelectorAll(".slide");
    const nextBtn = document.querySelector(".slider-btn.next");
    const prevBtn = document.querySelector(".slider-btn.prev");
    let currentIndex = 0;
    let autoPlayInterval;

    function showSlide(index) {
      slides.forEach((slide, i) => {
        slide.classList.remove("active");
        slide.style.display = "none";
        if (i === index) {
          slide.classList.add("active");
          slide.style.display = "block";
        }
      });
    }

    function nextSlide() {
      currentIndex = (currentIndex + 1) % slides.length;
      showSlide(currentIndex);
    }

    function prevSlide() {
      currentIndex = (currentIndex - 1 + slides.length) % slides.length;
      showSlide(currentIndex);
    }

    nextBtn.addEventListener("click", () => {
      nextSlide();
      resetAutoPlay();
    });

    prevBtn.addEventListener("click", () => {
      prevSlide();
      resetAutoPlay();
    });

    function startAutoPlay() {
      autoPlayInterval = setInterval(nextSlide, 5000);
    }

    function resetAutoPlay() {
      clearInterval(autoPlayInterval);
      startAutoPlay();
    }


    showSlide(currentIndex);
    startAutoPlay();
  });
</script>


</body>
</html>
