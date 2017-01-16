From: Jeffrey Altman <jaltman-hRzEac23uH1Wk0Htik3J/w@public.gmane.org>
Subject: Authentication Contexts for network file systems and Containers was
	Re: [LSF/MM ATTEND] FS jitter testing, network caching, Lustre, cluster
	filesystems.
Date: Mon, 16 Jan 2017 15:39:10 -0500
Message-ID: <c663a698-7116-76ac-25ee-c0ea35971a05@auristor.com>
References: <D863EDBD-277B-4CC3-854F-D57FF4501542@linuxhacker.ru>
	<20170116171708.GC2953@fieldses.org>
	<409e0dcb-0e6e-b37a-d8d1-039f92d466ac@auristor.com>
	<B992125F-7D3B-460A-9A6A-ACFBEA2607A8@oracle.com>
	<1484588818.2540.43.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5040095230011841222=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1484588818.2540.43.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lsf-pc-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a cryptographically signed message in MIME format.

--===============5040095230011841222==
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; boundary="------------ms000508080908050405010401"

This is a cryptographically signed message in MIME format.

--------------ms000508080908050405010401
Content-Type: multipart/mixed;
 boundary="------------049F6401F78BABEBFB8F74AC"

This is a multi-part message in MIME format.
--------------049F6401F78BABEBFB8F74AC
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 1/16/2017 12:46 PM, James Bottomley wrote:
>
> For identity, doesn't the UTS namespace do this?  If not, what is
> missing?
>=20
> James

James,

Thanks for posing the question.

Unless I'm missing something, the UTS namespace permits an alternate
'hostname' and NIS 'domainname' to be specified for local visibility to
the processes running in the container.

For an /afs network file system client (kafs, OpenAFS or AuriStorFS) the
kernel module must be able to associate each process with an
authentication context.  The AFS family of file systems have implemented
this binding as part of its Process Authentication Group (PAG) concept.
A PAG is a set of processes that share an authentication context.  The
authentication context includes:

 * network credentials necessary to establish new server connections
   to requisite network-based services.  These include not only the
   backing store for files and directories but any distributed database
   services managing location independence, replication, failover, etc.

 * established server connections to individual servers.  These
   connections are re-used for all requests from a process that shares
   the authentication context.

The network credentials might be a Kerberos ticket, a public key, the
result of a GSS-API exchange, or something else.   It depends on the
requirements of the security class.

The security properties of a PAG are:

 * a new PAG may be created by any process.  When a new PAG is
   created its membership is only the process that created it.

 * a process may remove itself from a PAG that it is a member of.

 * when a child process is created, it inherits a single PAG
   membership from the parent process.

 * it should not be possible to join a process to a PAG after
   process creation.  Although due to implementation limitations
   on some platforms you will find references to a child process
   being able to set the PAG of its parent process.

In the traditional PAG implementations used by AFS unix clients, there
has been a restriction of one PAG membership per process.  The Windows
client implements an extended model which is better suited to
multi-threaded processes.

 * a process can be a member of more than one PAG at a time

 * a process can select one of its PAGs as the default PAG

 * a thread can select one of the process' PAGs as its active
   PAG and if there is no active PAG, the process default PAG
   is used

This extended Authentication Group model works well for processes such
as web servers that need to execute requests in the authentication
context of the delegated identity and be able to rapidly switch contexts
for each request.

It is important to note that the network credentials stored in an
authentication context do not necessarily have any relationship to the
local machine.  It is also important to remember that network
credentials often have a relatively short lifetime and must be renewed
or replaced on a regular basis.

For containers I envision PAGs being used in the following manner:

 * A process running in the context of the host OS or one that has
   access to keys stored in a TPM or other secure keystore
   creates a new PAG for each container it is going to launch.

 * This process will then obtain the initial network credentials
   required by the container processes and store them into the PAG.

 * The initial Container process will then be created as a child
   process and inherits the PAG membership.  Each subsequent child
   process in the Container will in turn inherit the same PAG.

 * Periodically the host OS process will renew the network credentials
   for the PAG.  This avoids the need for the processes in the container
   to have any access to or knowledge of the network identity under
   which it is executing.

 * A process in the container could decide to resign from the
   inherited PAG and create its own PAG using credentials available
   to that process.  For example, a web server running in a container.

The end result is a PAG which spans both the host OS and the Container
processes.  The Container processes might not even know what credentials
they are running with.

Keyrings were created as a storage facility for the network credentials,
https://www.infradead.org/~dhowells/kafs/#keyrings, but keyrings are not
an authentication context.

While a file system can internally create an association between an
authentication content with a file descriptor once it is created and
with pages for write-back, I believe there would be benefit from a more
generic method of tracking authentication contexts in file descriptors
and pages.  In particular would be better defined behavior when a file
has been opened for "write" from processes associated with more than one
authentication context.

PAG creation and PAG token set manipulation in the AFS family of file
systems traditionally took place via the use of path-based ioctls.
Providing equivalent functionality to user-land is an open topic that
David Howells's submitted as a topic for LSF/MM.  See afs(setpag),
VIOC_GETPAG, VIOCUNPAG, VIC*TOK* and VIOCUNLOG:

  https://www.infradead.org/~dhowells/kafs/user_interface.html

While the PAG model has worked well for many decades it does
periodically run into problems with system design that assumes that
local system identities have the same meaning to network resources.  For
example, the problems that AFS is currently experiencing with systemd.
A good description of problem by Jonathan Billings can be found at


https://docs.google.com/document/d/1P27fP1uj-C8QdxDKMKtI-Qh00c5_9zJa4YHjn=
pB6ODM/pub

I hope this letter is helpful in describing the issues that the AFS
community has experienced and how we believe that authentication context
management can be used to enhance the usability of containers.





--------------049F6401F78BABEBFB8F74AC
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


--------------049F6401F78BABEBFB8F74AC--

--------------ms000508080908050405010401
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
hvcNAQkFMQ8XDTE3MDExNjIwMzkxMFowLwYJKoZIhvcNAQkEMSIEIBtf1Z05WUVJqmIMxZCz
w9B9K80D5ckFlFXKrXMn6939MF0GCSsGAQQBgjcQBDFQME4wOjELMAkGA1UEBhMCVVMxEjAQ
BgNVBAoTCUlkZW5UcnVzdDEXMBUGA1UEAxMOVHJ1c3RJRCBDQSBBMTICEEABWCMMfNcLLmEW
joaxC4swXwYLKoZIhvcNAQkQAgsxUKBOMDoxCzAJBgNVBAYTAlVTMRIwEAYDVQQKEwlJZGVu
VHJ1c3QxFzAVBgNVBAMTDlRydXN0SUQgQ0EgQTEyAhBAAVgjDHzXCy5hFo6GsQuLMGwGCSqG
SIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEqMAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggq
hkiG9w0DAgICAIAwDQYIKoZIhvcNAwICAUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwDQYJ
KoZIhvcNAQEBBQAEggEAYgoz3WHQ9qhXyejq2g43o+W5oWmKHz0+rDbi9fMmrHuwaF5nubVs
4Oqo+ZlaQ4fTOQ2ZiFd/atQjWm6Ao+3NvlM+o8au+/Oqq49MYVsVZr72cQfIuijKA7Oo2OAH
tZhXRJ7twXWZfXciebjhlxmgvHeKMx49PKlG2HD6fj7eFGessELkazG+P70HBocHHSieEgH8
AqW3UxEUwf5z4+EGcSj8NAsEXq5lbMYIoJ3yER9ACbeISKK9y1ThDDs1ahD6quQ/n93WtSvq
7m6ncnZdMDU9LeanBIUc+ohycBLqtsMq3OHMtF1PwXFeB689hjYTYeOk3E/SlqDtapYWlCUp
3wAAAAAAAA==
--------------ms000508080908050405010401--


--===============5040095230011841222==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============5040095230011841222==--
