From: =?iso-8859-1?Q?Istv=E1n_Kir=E1ly_-_LaKing?= <d250-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Subject: Re: [Lxc-users] how to make changes in conf file
Date: Mon, 5 Dec 2011 08:03:01 -0800 (PST)
Message-ID: <1323100981.74975.YahooMailNeo@web126109.mail.ne1.yahoo.com>
References: <CAHnfO6ymmvTi1bPZ3G4NAU87gCe0e+uk-E_8VfzRAWFtCs8Fag@mail.gmail.com>
Reply-To: =?iso-8859-1?Q?Istv=E1n_Kir=E1ly_-_LaKing?= <LaKing-86wdkw7il2A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAHnfO6ymmvTi1bPZ3G4NAU87gCe0e+uk-E_8VfzRAWFtCs8Fag-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

I think, you might want to look at libvirt.

Libvirt creates virbr0, and that has only one static address, while the res=
t is a dhcp territory. You can edit the xml file, free a range in the dhcp =
pool, or set it to static.=A0LaKing-86wdkw7il2A@public.gmane.org


D250 Laboratories
www.D250.hu


________________________________
 Von: nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
An: lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org; containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org =

Gesendet: 6:36 Montag, 5.Dezember 2011
Betreff: [Lxc-users] how to make changes in conf file
 =


Hi,
>
>I
 want the ip address to be assigned in order as the containers are =

started and not assigned by DHCP. For example :: container1:: 193.163.195.0=
1,container2:: 193.163.195.02 like wise if there is container30 :: 193.163.=
195.30, this should be its ip address.
>=A0
>What are changes that are to done in conf file of lxc so as to get this ki=
nd of address?
>
>Plz help me ASAP.
>
>Regards,
>Nishant Mungse
>
---------------------------------------------------------------------------=
---
All the data continuously generated in your IT infrastructure =

contains a definitive record of customers, application performance, =

security threats, fraudulent activity, and more. Splunk takes this =

data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
_______________________________________________
Lxc-users mailing list
Lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/lxc-users
