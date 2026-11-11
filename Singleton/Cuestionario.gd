extends RefCounted

# Same question wording and answer order as Dialogos/test.dialogue.
const PREGUNTAS = [
	"Dime algo, en las últimas dos semanas ¿Que tan seguido te has sentido con poco interés o placer en hacer cosas?",
	"Dime algo, en las últimas dos semanas ¿Te has sentido decaído(a), deprimido(a) o sin esperanzas?",
	"¿Y tú? ¿Has tenido dificultad para quedarte o permanecer dormido(a), o has dormido demasiado?",
	"¿Te has sentido cansado(a) o con poca energía?",
	"Durante las últimas dos semanas ¿Te has sentido sin apetito o has comido en exceso?",
	"¿Tú también te has sentido mal contigo mismo(a) - o que eres un fracaso o que has quedado mal contigo mismo(a) o con tu familia?",
	"En las últimas dos semanas ¿Has tenido dificultad para concentrarte en ciertas actividades, tales como leer o ver la televisión?",
	"Te has movido o has hablado tan lento que otras personas podrían haberlo notado? o lo contrario - muy inquieto(a) o agitado(a) que has estado moviéndote mucho más de lo normal?",
	"¿Has tenido pensamiento de que estarías mejor muerto(a) o de lastimarte de alguna manera?",
	"Recuerda todos los problemas que tuviste estas dos últimas semanas en tu vida cotidiana, ¿qué tanta dificultad te ha dado estos problemas para hacer tu trabajo, encargarte de las tareas del hogar, o llevarte bien con otras personas?",
]
const FRECUENCIAS = ["Ningún día", "Varios días", "Más de la mitad de los días", "Casi todos los días"]
const DIFICULTADES = ["No ha sido difícil", "Un poco difícil", "Muy difícil", "Extremadamente difícil"]

static func texto_respuesta(numero: int, valor: int) -> String:
	if valor < 0 or valor > 3:
		return "Sin responder"
	return DIFICULTADES[valor] if numero == 10 else FRECUENCIAS[valor]
