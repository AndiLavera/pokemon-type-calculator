@[ADI::Register]
struct PokemonConverter < ART::ParamConverterInterface
  def apply(request : HTTP::Request, configuration : Configuration) : Nil
    name = request.attributes.get "pokemon"

    POKEMON.each do |mon|
      next unless mon["name"]["english"] == name.to_s.capitalize

      request.attributes.set "pokemon", mon
      break
    end
  end
end

class PokemonController < ART::Controller
  @[ART::ParamConverter("pokemon", converter: PokemonConverter)]
  @[ART::Get("/pokemon/:pokemon")]
  def index(pokemon : Pokemon) : ART::Response
    type_effects = [] of Hash(String, String)
    pokemon["type"].each do |type|
      type_effects << TYPE_EFFECTIVENESS[type]
    end

    final_effects = {} of String => Int32 | Float64
    type_effects.each do |effect|
      effect.each do |key, value|
        if final_effects[key]?
          final_effects[key] = final_effects[key] * EFFECTIVENESS_MULTIPLIER[value]
        else
          final_effects[key] = EFFECTIVENESS_MULTIPLIER[value]
        end
      end
    end

    ART::Response.new(
      {
        pokemon:      pokemon,
        type_effects: final_effects,
      }.to_json,
      headers: HTTP::Headers{"content-type" => "application/json; charset=UTF-8"}
    )
  end
end
