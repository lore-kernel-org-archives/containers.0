From: Jeffrey Altman <jaltman-hRzEac23uH1Wk0Htik3J/w@public.gmane.org>
Subject: Re: [Lsf-pc] Authentication Contexts for network file systems and
	Containers was Re: [LSF/MM ATTEND] FS jitter testing, network caching,
	Lustre, cluster filesystems.
Date: Tue, 17 Jan 2017 12:10:58 -0500
Message-ID: <e97ca321-5231-52e3-3810-9964a6ab2466@auristor.com>
References: <D863EDBD-277B-4CC3-854F-D57FF4501542@linuxhacker.ru>
	<20170116171708.GC2953@fieldses.org>
	<409e0dcb-0e6e-b37a-d8d1-039f92d466ac@auristor.com>
	<B992125F-7D3B-460A-9A6A-ACFBEA2607A8@oracle.com>
	<1484588818.2540.43.camel@HansenPartnership.com>
	<c663a698-7116-76ac-25ee-c0ea35971a05@auristor.com>
	<1484600605.2540.73.camel@HansenPartnership.com>
	<7ba053a6-90af-ffc6-e8cd-9bfe0be41a18@auristor.com>
	<1484670853.4725.1.camel@primarydata.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1325187948138284653=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1484670853.4725.1.camel-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Trond Myklebust <trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>, "James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org" <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: "linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "lsf-pc-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <lsf-pc-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a cryptographically signed message in MIME format.

--===============1325187948138284653==
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; boundary="------------ms070202070802040602070406"

This is a cryptographically signed message in MIME format.

--------------ms070202070802040602070406
Content-Type: multipart/mixed;
 boundary="------------8562F0F8DE770FE653B815EB"

This is a multi-part message in MIME format.
--------------8562F0F8DE770FE653B815EB
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 1/17/2017 11:34 AM, Trond Myklebust wrote:
>>
>> https://docs.google.com/document/d/1P27fP1uj-C8QdxDKMKtI-Qh00c5_9zJa4
>> YHjnpB6ODM/pub
>>
>> Jeffrey Altman
>>
>=20
>=20
> There is the usual problem when you have to do an upcall in order to
> set up the authentication context for session based protocols, such as
> RPCSEC_GSS.
>=20

Trond,

Thanks for the thought but that is not the issue here.   systemd --user
launches processes as the user but those processes do not share the same
keyring as the processes started from the pam stack at logon.
Since the keyring doesn't match, the processes started by systemd --user
are in a different authentication context.

Setting the effective 'uid' is insufficient to gain access to the proper
authentication context.

I agree that upcalls are often a problem which is why the AFS family of
protocols does not use them.  Typically a process will be created in
userland for each PAG to push refreshed credentials to the kernel module.=


Jeffrey Altman


--------------8562F0F8DE770FE653B815EB
Content-Type: text/x-vcard; charset=utf-8;
 name="jaltman.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="jaltman.vcf"

begin:vcard
fn:Jeffrey Altman
n:Altman;Jeffrey
org:AuriStor, Inc.
adr:Suite 6B;;255 West 94Th Street;New York;New York;10025-6985;United St=
ates
email;internet:jaltman-hRzEac23uH1Wk0Htik3J/w@public.gmane.org
title:Founder and CEO
tel;work:+1-212-769-9018
note;quoted-printable:LinkedIn: https://www.linkedin.com/in/jeffreyaltman=
=3D0D=3D0A=3D
	Skype: jeffrey.e.altman=3D0D=3D0A=3D
=09
url:https://www.auristor.com/
version:2.1
end:vcard


--------------8562F0F8DE770FE653B815EB--

--------------ms070202070802040602070406
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCC
DIMwggXqMIIE0qADAgECAhBAAVgjDHzXCy5hFo6GsQuLMA0GCSqGSIb3DQEBCwUAMDoxCzAJ
BgNVBAYTAlVTMRIwEAYDVQQKEwlJZGVuVHJ1c3QxFzAVBgNVBAMTDlRydXN0SUQgQ0EgQTEy
MB4XDTE2MTEwMjAzMTkzMFoXDTE3MTEwMjAzMTkzMFowgYYxLTArBgNVBAsMJFZlcmlmaWVk
IEVtYWlsOiBqYWx0bWFuQGF1cmlzdG9yLmNvbTEjMCEGCSqGSIb3DQEJARYUamFsdG1hbkBh
dXJpc3Rvci5jb20xMDAuBgoJkiaJk/IsZAEBEyA3RjAwMDAwMTAwMDAwMTU4MjMwQzdDQTcw
MDAwMDdCMjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALtO/7veyX1tdA4aDvsO
c0gS/fICCTPlhS34dpRNmZYs2mvWb/xGRCKeflva8uZLFqsCE6ybMgz2IaB9rpowRcGSr/R7
CyY6HEBl3Rw0OkkslV7HQTxgp1fBXbGGoS8gOp6/ML64d5UJsMUM6NM59SzC77v8bi0sYkaT
q31SoiJrCcPiI0F2wZiESf1tguQONl3Emt9fhEokmlLRHAlv1DkRw2XeUOyUwVHIVgF1wnzR
4Ao86aYmym62Z669a6NPla3hqLmYk9w+ydTnzcWj0X6nhvaMxb7fhOUyj06Y5Mxhqye+dJg4
bPj/G+8OoNVY9l5h/qbJaWpSbDog4I0LxaUCAwEAAaOCAp0wggKZMA4GA1UdDwEB/wQEAwIF
oDCBhAYIKwYBBQUHAQEEeDB2MDAGCCsGAQUFBzABhiRodHRwOi8vY29tbWVyY2lhbC5vY3Nw
LmlkZW50cnVzdC5jb20wQgYIKwYBBQUHMAKGNmh0dHA6Ly92YWxpZGF0aW9uLmlkZW50cnVz
dC5jb20vY2VydHMvdHJ1c3RpZGNhYTEyLnA3YzAfBgNVHSMEGDAWgBSkc9rvaTWKdcygGXsI
MvhrieRC7DAJBgNVHRMEAjAAMIIBLAYDVR0gBIIBIzCCAR8wggEbBgtghkgBhvkvAAYLATCC
AQowSgYIKwYBBQUHAgEWPmh0dHBzOi8vc2VjdXJlLmlkZW50cnVzdC5jb20vY2VydGlmaWNh
dGVzL3BvbGljeS90cy9pbmRleC5odG1sMIG7BggrBgEFBQcCAjCBrhqBq1RoaXMgVHJ1c3RJ
RCBDZXJ0aWZpY2F0ZSBoYXMgYmVlbiBpc3N1ZWQgaW4gYWNjb3JkYW5jZSB3aXRoIApJZGVu
VHJ1c3QncyBUcnVzdElEIENlcnRpZmljYXRlIFBvbGljeSBmb3VuZCBhdCBodHRwczovL3Nl
Y3VyZS5pZGVudHJ1c3QuY29tL2NlcnRpZmljYXRlcy9wb2xpY3kvdHMvaW5kZXguaHRtbDBF
BgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vdmFsaWRhdGlvbi5pZGVudHJ1c3QuY29tL2NybC90
cnVzdGlkY2FhMTIuY3JsMB8GA1UdEQQYMBaBFGphbHRtYW5AYXVyaXN0b3IuY29tMB0GA1Ud
DgQWBBT6okll+NyYQTyBKCigoq5jFBzw3DAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUH
AwQwDQYJKoZIhvcNAQELBQADggEBABF9+YNU05P6tFiN8wvh52K+dgiUsQijFqN/tmwxqWHj
3TKxLwl8ZtK0F44FYcfeRXgE59bAxG8tZVRYBD7jY3qYEreri0x2DgJcA0oPfV1NHxM51t6h
ST09jpXEcthB4FJu3xWg8O6pB7Oq9Q9kkTjHfVLLru9B3BxrY+1NKZaSkaTBb0JGw6kCN2MM
rXrwPAdLlAWn5ywPRMqTIlgvhxtIQMv+dxpXhco9O5+ckMIdp1uBMJ82Hslfy3K9KCZvm6Cr
BG8C/fBo5TefVGuxKyOwROvup2gx1/KZWoIO0hyMNGzFPrijNZD5fAlZ11FcAJ9Why+pd5FY
mmJwln/BGPcwggaRMIIEeaADAgECAhEA+d5Wf8lNDHdw+WAbUtoVOzANBgkqhkiG9w0BAQsF
ADBKMQswCQYDVQQGEwJVUzESMBAGA1UEChMJSWRlblRydXN0MScwJQYDVQQDEx5JZGVuVHJ1
c3QgQ29tbWVyY2lhbCBSb290IENBIDEwHhcNMTUwMjE4MjIyNTE5WhcNMjMwMjE4MjIyNTE5
WjA6MQswCQYDVQQGEwJVUzESMBAGA1UEChMJSWRlblRydXN0MRcwFQYDVQQDEw5UcnVzdElE
IENBIEExMjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANGRTTzPCic0kq5L6ZrU
JWt5LE/n6tbPXPhGt2Egv7plJMoEpvVJJDqGqDYymaAsd8Hn9ZMAuKUEFdlx5PgCkfu7jL5z
giMNnAFVD9PyrsuF+poqmlxhlQ06sFY2hbhQkVVQ00KCNgUzKcBUIvjv04w+fhNPkwGW5M7A
e5K5OGFGwOoRck9GG6MUVKvTNkBw2/vNMOd29VGVTtR0tjH5PS5yDXss48Yl1P4hDStO2L4w
TsW2P37QGD27//XGN8K6amWB6F2XOgff/PmlQjQOORT95PmLkwwvma5nj0AS0CVp8kv0K2RH
V7GonllKpFDMT0CkxMQKwoj+tWEWJTiDKSsCAwEAAaOCAoAwggJ8MIGJBggrBgEFBQcBAQR9
MHswMAYIKwYBBQUHMAGGJGh0dHA6Ly9jb21tZXJjaWFsLm9jc3AuaWRlbnRydXN0LmNvbTBH
BggrBgEFBQcwAoY7aHR0cDovL3ZhbGlkYXRpb24uaWRlbnRydXN0LmNvbS9yb290cy9jb21t
ZXJjaWFscm9vdGNhMS5wN2MwHwYDVR0jBBgwFoAU7UQZwNPwBovupHu+QucmVMiONnYwDwYD
VR0TAQH/BAUwAwEB/zCCASAGA1UdIASCARcwggETMIIBDwYEVR0gADCCAQUwggEBBggrBgEF
BQcCAjCB9DBFFj5odHRwczovL3NlY3VyZS5pZGVudHJ1c3QuY29tL2NlcnRpZmljYXRlcy9w
b2xpY3kvdHMvaW5kZXguaHRtbDADAgEBGoGqVGhpcyBUcnVzdElEIENlcnRpZmljYXRlIGhh
cyBiZWVuIGlzc3VlZCBpbiBhY2NvcmRhbmNlIHdpdGggSWRlblRydXN0J3MgVHJ1c3RJRCBD
ZXJ0aWZpY2F0ZSBQb2xpY3kgZm91bmQgYXQgaHR0cHM6Ly9zZWN1cmUuaWRlbnRydXN0LmNv
bS9jZXJ0aWZpY2F0ZXMvcG9saWN5L3RzL2luZGV4Lmh0bWwwSgYDVR0fBEMwQTA/oD2gO4Y5
aHR0cDovL3ZhbGlkYXRpb24uaWRlbnRydXN0LmNvbS9jcmwvY29tbWVyY2lhbHJvb3RjYTEu
Y3JsMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDBDAOBgNVHQ8BAf8EBAMCAYYwHQYD
VR0OBBYEFKRz2u9pNYp1zKAZewgy+GuJ5ELsMA0GCSqGSIb3DQEBCwUAA4ICAQAN4YKu0vv0
62MZfg+xMSNUXYKvHwvZIk+6H1pUmivyDI4I6A3wWzxlr83ZJm0oGIF6PBsbgKJ/fhyyIzb+
vAYFJmyI8I/0mGlc+nIQNuV2XY8cypPoVJKgpnzp/7cECXkX8R4NyPtEn8KecbNdGBdEaG4a
7AkZ3ujlJofZqYdHxN29tZPdDlZ8fR36/mAFeCEq0wOtOOc0Eyhs29+9MIZYjyxaPoTS+l8x
LcuYX3RWlirRyH6RPfeAi5kySOEhG1quNHe06QIwpigjyFT6v/vRqoIBr7WpDOSt1VzXPVbS
j1PcWBgkwyGKHlQUOuSbHbHcjOD8w8wHSDbL+L2he8hNN54doy1e1wJHKmnfb0uBAeISoxRb
JnMMWvgAlH5FVrQWlgajeH/6NbYbBSRxALuEOqEQepmJM6qz4oD2sxdq4GMN5adAdYEswkY/
o0bRKyFXTD3mdqeRXce0jYQbWm7oapqSZBccFvUgYOrB78tB6c1bxIgaQKRShtWR1zMM0Jfq
UfD9u8Fg7G5SVO0IG/GcxkSvZeRjhYcbTfqF2eAgprpyzLWmdr0mou3bv1Sq4OuBhmTQCnqx
AXr4yVTRYHkp5lCvRgeJAme1OTVpVPth/O7HJ7VuEP9GOr6kCXCXmjB4P3UJ2oU0NqfoQdcS
SSt9hliALnExTEjii20B2nSDojGCAxQwggMQAgEBME4wOjELMAkGA1UEBhMCVVMxEjAQBgNV
BAoTCUlkZW5UcnVzdDEXMBUGA1UEAxMOVHJ1c3RJRCBDQSBBMTICEEABWCMMfNcLLmEWjoax
C4swDQYJYIZIAWUDBAIBBQCgggGXMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZI
hvcNAQkFMQ8XDTE3MDExNzE3MTA1OFowLwYJKoZIhvcNAQkEMSIEIN4QD2N4uqsGAVAqedPA
vEo86ySMrK/AZRrheHCjAQ50MF0GCSsGAQQBgjcQBDFQME4wOjELMAkGA1UEBhMCVVMxEjAQ
BgNVBAoTCUlkZW5UcnVzdDEXMBUGA1UEAxMOVHJ1c3RJRCBDQSBBMTICEEABWCMMfNcLLmEW
joaxC4swXwYLKoZIhvcNAQkQAgsxUKBOMDoxCzAJBgNVBAYTAlVTMRIwEAYDVQQKEwlJZGVu
VHJ1c3QxFzAVBgNVBAMTDlRydXN0SUQgQ0EgQTEyAhBAAVgjDHzXCy5hFo6GsQuLMGwGCSqG
SIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEqMAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggq
hkiG9w0DAgICAIAwDQYIKoZIhvcNAwICAUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwDQYJ
KoZIhvcNAQEBBQAEggEABHEVm3w3+RxbrYmSF6kJaTdms1BjugCSChCrya2MjsR/ENu721t/
4MlklMijRfa151gocWUdeCqnSwbIayHfwBPFgbn+CBk+zvh97PDFfxACBMTQInzft1pLq8Uh
tj/RebiGM6pVD2arEq087YQn0gNmRf7zHvmPOM14nI/subZhWTdCeKZnqTRNdSJWpkxpZX1d
dAx7VX7PrLPfTNpyMsRj4eQroFWK2YJKchj7Hxqq+AZj5HUS4029T+AyZe/OTzl1j2vePqqo
NZiWyw11NtphSAcQmZ1HqrPZgL0nZWtEI0NDb3fdyUyGUMgiJ2krBF0nJGN6HJO5TprRGxYQ
QgAAAAAAAA==
--------------ms070202070802040602070406--


--===============1325187948138284653==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============1325187948138284653==--
