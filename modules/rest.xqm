xquery version "3.0";


module namespace api = "http://acdh.oeaw.ac.at/apps/xtoks/api";
declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace config = "http://acdh.oeaw.ac.at/apps/xtoks/config" at "config.xqm";
import module namespace tok = "http://acdh.oeaw.ac.at/apps/xtoks/tokenize" at "tok.xqm";
import module namespace profile = "http://acdh.oeaw.ac.at/apps/xtoks/profile" at "profile.xqm";


(: Remove Newlines :)
declare
    %rest:POST("{$data}")
    %rest:path("/xtoks/rmNl")
    %rest:consumes("application/xml")
    %rest:produces("application/xml")
function api:rmNl($data as document-node()) {
    tok:rmNl($data, ())
};




(: Tokenizer Endpoints :)
declare
    %rest:POST("{$data}")
    %rest:path("/xtoks/tokenize/{$profile-id}")
    %rest:query-param("format", "{$format}", "doc")
    %rest:consumes("application/xml")
    %rest:produces("application/xml")
    %output:method("xml")
    %output:indent("yes")
function api:tokenize-xml($data as document-node(), $profile-id as xs:string, $format as xs:string*) {
    if (profile:home($profile-id) != "")
    then tok:tokenize($data, $profile-id, $format[1])
    else <error>unknown profile {$profile-id}</error>
};


declare
    %rest:POST("{$data}")
    %rest:path("/xtoks/tokenize/{$profile-id}")
    %rest:consumes("application/xml")
    %rest:produces("text/plain")
    %output:method("text")
function api:tokenize-txt($data as document-node(), $profile-id as xs:string) {
    if (profile:home($profile-id) != "")
    then tok:tokenize($data, $profile-id, "txt")
    else <error>unknown profile {$profile-id}</error>
};


(: Make vertical of document with tokens :)
declare
    %rest:POST("{$data}")
    %rest:path("/xtoks/verticalize/{$profile-id}")
    %rest:consumes("application/xml")
    %rest:produces("text/plain")
    %output:method("text")
function api:verticalize($data as document-node(), $profile-id as xs:string) {
    if (profile:home($profile-id) != "")
    then 
        let $vert := tok:tei2vert($data, $profile-id)
        return tok:vert2txt($vert, $profile-id)
    else <error>unknown profile {$profile-id}</error> 
};


(: Profile Management :)
declare 
    %rest:GET 
    %rest:path("/xtoks/profile")
    %rest:produces("application/xml")
    %output:method("xml")
    %output:indent("yes")
function api:list-profiles() {
    <profiles>{
            for $p in collection($config:profiles)//profile 
            return <profile id="{$p/@id}" created="{$p/@created}" last-updated="{$p/@last-updated}">{$p/about}</profile>
    }</profiles>
};

declare 
    %rest:GET 
    %rest:path("/xtoks/profile/{$profile-id}")
    %rest:produces("application/xml")
function api:read-profile($profile-id as xs:string){
    profile:read($profile-id)
};

declare 
    %rest:POST("{$data}") 
    %rest:path("/xtoks/profile")
    %rest:produces("application/xml")
    %rest:consumes("application/xml")
function api:create-profile($data as document-node()) {
    let $id := profile:create($data)
    return profile:read($id)
};

declare 
    %rest:PUT("{$data}") 
    %rest:path("/xtoks/profile/{$profile-id}")
    %rest:produces("application/xml")
    %rest:consumes("application/xml")
function api:update-profile($data as document-node(), $profile-id as xs:string) {
    if (profile:home($profile-id) != "")
    then 
        let $update := profile:update($profile-id, $data)
        return profile:read($profile-id)
    else <error>unknown profile {$profile-id}</error> 
};

declare 
    %rest:DELETE 
    %rest:path("/xtoks/profile/{$profile-id}")
    %rest:produces("application/xml")
function api:delete-profile($profile-id as xs:string) {
    if (profile:home($profile-id) != "")
    then 
        profile:delete($profile-id)
    else <error>unknown profile {$profile-id}</error>
};