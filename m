From: "lists.jc.michel-/aRvmaKoZxNWk0Htik3J/w@public.gmane.org" <lists.jc.michel-/aRvmaKoZxNWk0Htik3J/w@public.gmane.org>
Subject: Re: [Lxc-users] How assign the IP address sequentially?
Date: Wed, 7 Dec 2011 11:54:50 +0100
Message-ID: <EE71D393-4CD4-4735-BAA7-F6555DC3E208__48976.5500453815$1323256720$gmane$org@symetrie.com>
References: <CAHnfO6yN1=DxABr=3rS=-VrkaZxLakKb7pFmnqKncE63qSN_7g@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAHnfO6yN1=DxABr=3rS=-VrkaZxLakKb7pFmnqKncE63qSN_7g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,


Le 7 d=E9c. 2011 =E0 07:22, nishant mungse a =E9crit :
> I want to assign the ip address of containers sequentially for eg:: conta=
iner1 ::195.168.206.1 container2::195.168.206.2 like this. =



I think you can do this simply by editing the files in your container once =
created :
/var/lib/lxc/your-container-name/rootfs/etc/network/interfaces

So build a script to create your container and edit its ip.
