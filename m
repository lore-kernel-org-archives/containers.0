From: "Ward, David - 0663 - MITLL" <david.ward-OVIABD91gjs3uPMLIKxrzw@public.gmane.org>
Subject: netns: Issues with deleting virtual interfaces during namespace
	cleanup
Date: Sat, 26 Feb 2011 11:59:27 -0500
Message-ID: <4D69316F.4000606@ll.mit.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1535274412188528459=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

--===============1535274412188528459==
Content-Language: en-US
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
	micalg=sha1; boundary="------------ms020709040807020402040204"

--------------ms020709040807020402040204
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

(Apologies for the cross-post, but Thunderbird messed up the formatting=20
when I sent this originally, and then I realized I sent it to the wrong=20
list.)

A patch was applied to the kernel in November 2008 that deletes virtual=20
network interfaces when network namespaces are cleaned up=20
(d0c082cea6dfb9b674b4f6e1e84025662dbd24e8).  A discussion about this=20
patch took place on this list=20
(https://lists.linux-foundation.org/pipermail/containers/2008-October/013=
460.html),=20
where Daniel Lezcano wrote:

 > After discussing with Benjamin, this patch means an user can no longer=

 > manage a pool of virtual devices because they will be automatically
 > destroyed when the namespace exits. I don't think it is a big concern,=

 > but just in case I am asking :)

I currently have two use cases where this behavior is not desirable:

   1. I use a veth pair device to connect two containers together (as
      opposed to connecting a container to the host).  To do this, I
      create the veth pair device manually in the host with iproute2
      ("ip link add type veth").  Then when I start each container, it
      pulls in one of the interfaces of the veth pair device with
      "lxc.network.type =3D phys".  When I stop one of the containers, it=
s
      interface to the veth pair device is deleted instead of moved back
      to the host, so I can not just start the stopped container again
      and re-establish the same link.
   2. I start a process in the host that creates a TUN/TAP interface,
      such as a VPN client.  I pull the TUN/TAP interface into the
      container with "lxc.network.type =3D phys".  When the container
      exits, the TUN/TAP interface is deleted because it is a virtual
      interface, while the VPN client process continues to run in the
      host.  Again I can not just start the container again with the
      same connection; I have to restart the VPN client.

It makes sense that virtual network interfaces that get created inside a =

container should be deleted when the container exits.  However, I feel=20
that network interfaces from the host that get assigned to the container =

should be returned to the host when the container exits, whether they=20
are physical or virtual.

Can the kernel distinguish between network interfaces that were created=20
inside the namespace, and network interfaces that were moved there?

David


--------------ms020709040807020402040204
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
b3JhdG9yeTEMMAoGA1UECxMDUEtJMRMwEQYDVQQDEwpNSVRMTCBDQS0yMB4XDTEwMDgxMjEz
NTY0OVoXDTExMDgxMjEzNTY0OVowXzELMAkGA1UEBhMCVVMxHzAdBgNVBAoTFk1JVCBMaW5j
b2xuIExhYm9yYXRvcnkxDzANBgNVBAsTBlBlb3BsZTEeMBwGA1UEAxMVV2FyZC5EYXZpZC5Q
LjUwMDExNDU5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzbK0X5evOHRZ6R2s
EKR1FoTN5BXfLREbFBdxumzb5Ap1mOOj6lev5pAyZ6DgWm6O1jcr7jaWSIluqhCOjEYxT03e
Uyf2APQva7Wp52J48FE1MDBMTx5LalMZ6QuycgtiZOJKCuC82SEIYjVzi+rolEpiQ94Y0GF9
8GEKXu3RuYI0PIOfPOdqizdoiEKRhTuKpK2acWB0lRwm7/QwJ1VwwsYT/t8a8u/mZ283Hv8V
XlFmY8sJZs1MWJ2si5TXVX78pf/hj2dh8j/6plEGyKuywVftDr9hvvLvWOstNY3a/V/nzLod
LGxEGHwDTAPwcvnM9bCw/KH8SizA3nPiYK3BtQIDAQABo4IBnTCCAZkwHQYDVR0OBBYEFE+y
gGACWUAyu4BrKBDod2IzlaKaMA4GA1UdDwEB/wQEAwIFIDAfBgNVHSMEGDAWgBSOSn2JoWMX
HIGINFc3JkVeGYp+JDAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3JsLmxsLm1pdC5lZHUv
Z2V0Y3JsL0xMQ0EyMGIGCCsGAQUFBwEBBFYwVDAtBggrBgEFBQcwAoYhaHR0cDovL2NybC5s
bC5taXQuZWR1L2dldHRvL0xMQ0EyMCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5sbC5taXQu
ZWR1LzAMBgNVHRMBAf8EAjAAMD0GCSsGAQQBgjcVBwQwMC4GJisGAQQBgjcVCIOD5R2H7Kdm
hq2HFYPq8EWFtqEfHYXr0HCD6+0gAgFkAgEEMCUGA1UdJQQeMBwGBFUdJQAGCCsGAQUFBwME
BgorBgEEAYI3CgMEMBgGA1UdIAQRMA8wDQYLKoZIhvcSAgEDAQgwIAYDVR0RBBkwF4EVZGF2
aWQud2FyZEBsbC5taXQuZWR1MA0GCSqGSIb3DQEBCwUAA4IBAQBsXUgqbV1vQBnwZ4MEa3zu
q89rtpFzR0G+6Q44ZyQsuh4AAjQCfYJQr6HK0o82sjRANYlteAfCDdJRRAEOpyZxgrxdf3RC
vrgsZFdSKNeW0/WT5lZyDfb675S2njMsFbCa1njgenWhhPyXsCv1Gtv7lkjpfuziXjQNuM/R
F2hjU+Zg6sIsT16fBLHw4J8XOWqikwxHVr2yLVGnUT8bSYGS4pkktfk2R/Aq+KJ/w135r63G
XRrAmqt3kp7qWmDUgrTYk43nLqCW5E1ilg9tjT+YvYbAdKhg7wN7SpJoG0aC8AJR7C7AT4XV
dn6vuedgAx1E5//GYK5tpoBfPJ8H2yANMYIDKjCCAyYCAQEwXzBRMQswCQYDVQQGEwJVUzEf
MB0GA1UEChMWTUlUIExpbmNvbG4gTGFib3JhdG9yeTEMMAoGA1UECxMDUEtJMRMwEQYDVQQD
EwpNSVRMTCBDQS0yAgoUALAlAAAAAAvsMAkGBSsOAwIaBQCgggGgMBgGCSqGSIb3DQEJAzEL
BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTExMDIyNjE2NTkyN1owIwYJKoZIhvcNAQkE
MRYEFMimBLceyqT1GazjmeH9uT5YMGKhMF8GCSqGSIb3DQEJDzFSMFAwCwYJYIZIAWUDBAEC
MAoGCCqGSIb3DQMHMA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0DAgIBQDAHBgUrDgMCBzAN
BggqhkiG9w0DAgIBKDBuBgkrBgEEAYI3EAQxYTBfMFExCzAJBgNVBAYTAlVTMR8wHQYDVQQK
ExZNSVQgTGluY29sbiBMYWJvcmF0b3J5MQwwCgYDVQQLEwNQS0kxEzARBgNVBAMTCk1JVExM
IENBLTICCnCu9NkAAAAAALQwcAYLKoZIhvcNAQkQAgsxYaBfMFExCzAJBgNVBAYTAlVTMR8w
HQYDVQQKExZNSVQgTGluY29sbiBMYWJvcmF0b3J5MQwwCgYDVQQLEwNQS0kxEzARBgNVBAMT
Ck1JVExMIENBLTICCnCu9NkAAAAAALQwDQYJKoZIhvcNAQEBBQAEggEANfLIh25qTfEq7UnY
cBP1oZz2xmPiETreJIrzV4rVlYryLU178hYywRS7iRKSqRWn39mildCaNhJTa1e4XxjCl9GR
i0ojNfT8+8oqeeRddSRU4u8dZ4w2x4bNJFGlZJbtAMeeQnH8TZYJv9rRflJjLIH8NowJBUov
oRpo9to5Fd/kR3jhMSODBUWVEp1Obmh0hw+aDa7CBPbH6dI0zojAMWC7s+NRGmKlCd2kH9J3
ZO5nxxBTAl/gowxs08GGgT5BwLIP8CPCowHmf/W7SdwmmfiLNo82AFA2bO9XvLVWTcXV76ks
UuuzmQwSu5XGlJ9CmHFEDb5z3zWrj44RmrwXmgAAAAAAAA==
--------------ms020709040807020402040204--

--===============1535274412188528459==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============1535274412188528459==--
