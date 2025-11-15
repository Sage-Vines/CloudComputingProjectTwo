<!-- super chatty template comment: this html gets jammed into a configmap and mounted -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>${title}</title>
    <style>
      :root {
        color-scheme: light dark;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        --accent: ${accent};
      }
      body {
        margin: 0;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 1rem;
        padding: 2rem;
        background: radial-gradient(circle at top, ${bg_start}, ${bg_end});
        position: relative;
        overflow: hidden;
      }
      body::before,
      body::after {
        content: "";
        position: absolute;
        width: 420px;
        height: 420px;
        border-radius: 999px;
        background: color-mix(in srgb, var(--accent) 25%, transparent);
        filter: blur(40px);
        animation: floaty 18s infinite alternate ease-in-out;
        z-index: 0;
      }
      body::before {
        top: -120px;
        left: -80px;
      }
      body::after {
        bottom: -140px;
        right: -60px;
        animation-delay: 4s;
      }
      main {
        padding: 2rem 3rem;
        border-radius: 1rem;
        border: 1px solid rgb(0 0 0 / 0.1);
        background: rgb(255 255 255 / 0.8);
        color: #111;
        backdrop-filter: blur(12px);
        box-shadow: 0 25px ${shadow} rgb(15 23 42 / 0.15);
        position: relative;
        z-index: 1;
      }
      @media (prefers-color-scheme: dark) {
        main {
          background: rgb(20 20 20 / 0.8);
          color: #f6f6f6;
          border-color: rgb(255 255 255 / 0.2);
        }
      }
      h1 {
        margin-top: 0;
        font-size: clamp(2rem, 5vw, 3rem);
      }
      p {
        margin: 0;
        font-size: 1.25rem;
      }
      footer {
        font-size: 0.875rem;
        opacity: 0.7;
      }
      .cta {
        margin-top: 1.5rem;
        display: inline-flex;
        align-items: center;
        gap: 0.4rem;
        padding: 0.65rem 1.3rem;
        border-radius: 999px;
        background: var(--accent);
        color: white;
        text-decoration: none;
        font-weight: 600;
        box-shadow: 0 12px 25px rgb(37 99 235 / 0.35);
        transition: transform 200ms ease, box-shadow 200ms ease;
      }
      .cta:hover {
        transform: translateY(-2px);
        box-shadow: 0 18px 35px rgb(37 99 235 / 0.45);
      }
      @keyframes floaty {
        from {
          transform: translateY(0px) scale(1);
        }
        to {
          transform: translateY(40px) scale(1.05);
        }
      }
      ul.features {
        list-style: none;
        display: flex;
        flex-wrap: wrap;
        gap: 0.5rem;
        padding: 0;
        margin: 1.5rem 0 0;
      }
      ul.features li {
        border-radius: 999px;
        padding: 0.4rem 0.9rem;
        background: color-mix(in srgb, var(--accent) 80%, transparent);
        color: white;
        font-size: 0.9rem;
        letter-spacing: 0.02em;
      }
    </style>
  </head>
  <body>
    <main>
      <h1>${title}</h1>
      <p>${message}</p>
%{ if length(highlights) > 0 ~}
      <ul class="features">
%{ for feature in highlights ~}
        <li>${feature}</li>
%{ endfor ~}
      </ul>
%{ endif ~}
%{ if length(cta_label) > 0 && length(cta_url) > 0 ~}
      <a class="cta" href="${cta_url}" target="_blank" rel="noreferrer">
        ${cta_label} →
      </a>
%{ endif ~}
      <footer>Environment: ${env}</footer>
    </main>
  </body>
</html>

