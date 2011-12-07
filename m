From: nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Lxc-users] How assign the IP address sequentially?
Date: Wed, 7 Dec 2011 16:36:34 +0530
Message-ID: <CAHnfO6z=Sdc8dUiz8uLnqK4U=xee5WCOGKgefAeL48kwP6E=eQ@mail.gmail.com>
References: <CAHnfO6yN1=DxABr=3rS=-VrkaZxLakKb7pFmnqKncE63qSN_7g@mail.gmail.com>
	<EE71D393-4CD4-4735-BAA7-F6555DC3E208@symetrie.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <EE71D393-4CD4-4735-BAA7-F6555DC3E208-/aRvmaKoZxNWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "lists.jc.michel-/aRvmaKoZxNWk0Htik3J/w@public.gmane.org" <lists.jc.michel-/aRvmaKoZxNWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

Thanks 4 reply dude.
It is working properly using this method, is there any other way because if
i have 1000 containers then each time i have to open each containers file
and edit that file which will definitely take much time????

Correct me if I am wrong.

On Wed, Dec 7, 2011 at 4:24 PM, lists.jc.michel-/aRvmaKoZxNWk0Htik3J/w@public.gmane.org <
lists.jc.michel-/aRvmaKoZxNWk0Htik3J/w@public.gmane.org> wrote:

> Hi,
>
>
> Le 7 d=E9c. 2011 =E0 07:22, nishant mungse a =E9crit :
> > I want to assign the ip address of containers sequentially for eg::
> container1 ::195.168.206.1 container2::195.168.206.2 like this.
>
>
> I think you can do this simply by editing the files in your container once
> created :
> /var/lib/lxc/your-container-name/rootfs/etc/network/interfaces
>
> So build a script to create your container and edit its ip.

Hi,

Thanks 4 reply dude.
It is working properly using this method, is there any other way because if
i have 1000 containers then each time i have to open each containers file
and edit that file which will definitely take much time????

Correct me if I am wrong.
