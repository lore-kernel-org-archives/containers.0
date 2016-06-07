From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: Deploy specific iptables ruleset for each container...
Date: Tue, 07 Jun 2016 08:30:02 -0700
Message-ID: <1465313402.2310.5.camel@HansenPartnership.com>
References: <1037489545.134365.1465266607461.JavaMail.yahoo.ref@mail.yahoo.com>
	<1037489545.134365.1465266607461.JavaMail.yahoo@mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1037489545.134365.1465266607461.JavaMail.yahoo-sAHhhX/85wgbqTNvkayDYw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?ISO-8859-1?Q?Sebasti=E1n?= Maruca <seba-iesXmtczecS4Tu3zPC53fQ@public.gmane.org>, =?ISO-8859-1?Q?Sebasti=E1n?= Maruca <juanperiz-/E1597aS9LQMlKAeRRkD2Q@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gVHVlLCAyMDE2LTA2LTA3IGF0IDAyOjMwICswMDAwLCBTZWJhc3Rpw6FuIE1hcnVjYSB2aWEg
Q29udGFpbmVycwp3cm90ZToKPiBIaSB0byBldmVyeW9uZSEKPiBJcyBpdCBwb3NzaWJsZSB0byBk
ZXBsb3kgYSAiY2VudHJhbCIgaXB0YWJsZXMgcnVsZXNldCBhdCBhIEhvc3QsYW5kCj4gdGhlbiwg
ZGVwbG95IHNldmVyYWwgImlzb2xhdGVkIiBpcHRhYmxlcyBydWxlc2V0cywgb25lIGZvciBlYWNo
Cj4gY29udGFpbmVyPwo+IEknZCBsaWtlIHRvIGhhdmUgYSB0aGlzICJjZW50cmFsIiBpcHRhYmxl
cyB0byBjaGFpbiBiYXNpYyBydWxlcyxhbmQgCj4gZWFjaCBvbmUgb2YgdGhlbSBoYXZlIHRyaXZp
YWwgcnVsZXNldHMsIHNvIGFzIHRvIHNwZWFrIG9mIGEibXVsdGkKPiAtdGVuYW50IiBJUFRhYmxl
cy4KCkl0IGRlcGVuZHMgd2hhdCB5b3UgbWVhbiBieSAiZGVwbG95Ii4gIEZpcmV3YWxsIHJ1bGUg
c2V0cyBhcmUgMToxIHdpdGgKbmV0d29yayBuYW1lc3BhY2VzLCBzbyBpdCBpc24ndCBwb3NzaWJs
ZSB0byAiaW5oZXJpdCIgcnVsZXMgZnJvbSB0aGUKcGFyZW50IG5ldG5zLiAgSXQgaXMsIGhvd2V2
ZXIsIHBlcmZlY3RseSBwb3NzaWJsZSB0byBydW4gYSB2ZXRoIHBhaXIKYmV0d2VlbiB0d28gZGlm
ZmVyZW50IG5ldG5zIGFuZCBhcHBseSBkaWZmZXJlbnQgZmlyZXdhbGwgcnVsZXMgb24gZWFjaApl
bmQgd2l0aCBlYWNoIHJ1bGUgc2V0IGJlaW5nIGluIGl0cyBvd24gbmV0bnMuICBJdCBzb3VuZHMg
bGlrZSB0aGlzCmNvdWxkIGNvdmVyIHlvdXIgdXNlIGNhc2UuCgpKYW1lcwoKCl9fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBs
aXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5s
aW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
