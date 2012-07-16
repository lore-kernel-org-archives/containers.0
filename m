From: "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH v2] ns: do not block exit_task_namespaces() for a long time
Date: Mon, 16 Jul 2012 19:39:43 +0300
Message-ID: <20120716163943.GA15156@otc-wbsnb-06>
References: <20120713140806.b3d0fda8.akpm@linux-foundation.org>
	<1342451364-14787-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1342453174.4648.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6436946209527063367=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1342453174.4648.6.camel-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Dmitry V. Levin" <ldv-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============6436946209527063367==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="J2SCkAp4GZ/dPZZf"
Content-Disposition: inline


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 16, 2012 at 03:39:36PM +0000, Myklebust, Trond wrote:
> On Mon, 2012-07-16 at 18:09 +0300, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> >=20
> > On exiting of the last task in a namespace we need to trigger freeing of
> > the namespace. Currently, we call synchronize_rcu() and free_nsproxy()
> > directly on do_exit() path.
> >=20
> > On my machine synchronize_rcu() blocks for about 0.01 seconds. For
> > comparing: normal exit_group() syscall takes less than 0.0003 seconds.
> >=20
> > Let's offload synchronize_rcu() and free_nsproxy() to a workqueue.
> >=20
> > I also move synchronize_rcu() inside free_nsproxy(). It fixes racy
> > put_nsproxy() which calls free_nsproxy() without synchronize_rcu().
> > I guess it was missed during switch to RCU (see cf7b708).
> >=20
> > Microbenchmark:
> >=20
> > : #define _GNU_SOURCE
> > : #include <unistd.h>
> > : #include <sched.h>
> > : #include <stdlib.h>
> > : #include <sys/wait.h>
> > :
> > : int
> > : main(void)
> > : {
> > :       int i;
> > :       for (i =3D 0; i < 1024; i++) {
> > :               if (fork()) {
> > :                       wait(NULL);
> > :                       continue;
> > :               }
> > :               unshare(CLONE_NEWIPC);
> > :               exit(0);
> > :       }
> > :       return 0;
> > : }
> >=20
> > Before the patch:
> >=20
> > real    0m8.335s
> > user    0m0.000s
> > sys     0m0.265s
> >=20
> > After:
> >=20
> > real    0m0.569s
> > user    0m0.001s
> > sys     0m0.154s
> >=20
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> > Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
> > ---
> >=20
> > v2:
> >  - Updated description.
> >=20
> > ---
> >  include/linux/nsproxy.h |    1 +
> >  kernel/nsproxy.c        |   34 +++++++++++++++++++++++-----------
> >  2 files changed, 24 insertions(+), 11 deletions(-)
> >=20
> > diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
> > index cc37a55..1d26be7 100644
> > --- a/include/linux/nsproxy.h
> > +++ b/include/linux/nsproxy.h
> > @@ -24,6 +24,7 @@ struct fs_struct;
> >   */
> >  struct nsproxy {
> >  	atomic_t count;
> > +	struct work_struct free_nsproxy_work;
> >  	struct uts_namespace *uts_ns;
> >  	struct ipc_namespace *ipc_ns;
> >  	struct mnt_namespace *mnt_ns;
> > diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> > index b576f7f..ebc7d40 100644
> > --- a/kernel/nsproxy.c
> > +++ b/kernel/nsproxy.c
> > @@ -41,13 +41,17 @@ struct nsproxy init_nsproxy =3D {
> >  #endif
> >  };
> > =20
> > +static void free_nsproxy_work(struct work_struct *work);
> > +
> >  static inline struct nsproxy *create_nsproxy(void)
> >  {
> >  	struct nsproxy *nsproxy;
> > =20
> >  	nsproxy =3D kmem_cache_alloc(nsproxy_cachep, GFP_KERNEL);
> > -	if (nsproxy)
> > +	if (nsproxy) {
> >  		atomic_set(&nsproxy->count, 1);
> > +		INIT_WORK(&nsproxy->free_nsproxy_work, free_nsproxy_work);
> > +	}
> >  	return nsproxy;
> >  }
> > =20
> > @@ -166,6 +170,14 @@ out:
> > =20
> >  void free_nsproxy(struct nsproxy *ns)
> >  {
> > +	/*
> > +	 * wait for others to get what they want from this nsproxy.
> > +	 *
> > +	 * cannot release this nsproxy via the call_rcu() since
> > +	 * put_mnt_ns() will want to sleep
> > +	 */
> > +	synchronize_rcu();
> > +
> >  	if (ns->mnt_ns)
> >  		put_mnt_ns(ns->mnt_ns);
> >  	if (ns->uts_ns)
> > @@ -178,6 +190,14 @@ void free_nsproxy(struct nsproxy *ns)
> >  	kmem_cache_free(nsproxy_cachep, ns);
> >  }
> > =20
> > +static void free_nsproxy_work(struct work_struct *work)
> > +{
> > +	struct nsproxy *ns =3D container_of(work, struct nsproxy,
> > +			free_nsproxy_work);
> > +
> > +	free_nsproxy(ns);
> > +}
> > +
> >  /*
> >   * Called from unshare. Unshare all the namespaces part of nsproxy.
> >   * On success, returns the new nsproxy.
> > @@ -215,16 +235,8 @@ void switch_task_namespaces(struct task_struct *p,=
 struct nsproxy *new)
> > =20
> >  	rcu_assign_pointer(p->nsproxy, new);
> > =20
> > -	if (ns && atomic_dec_and_test(&ns->count)) {
> > -		/*
> > -		 * wait for others to get what they want from this nsproxy.
> > -		 *
> > -		 * cannot release this nsproxy via the call_rcu() since
> > -		 * put_mnt_ns() will want to sleep
> > -		 */
> > -		synchronize_rcu();
> > -		free_nsproxy(ns);
> > -	}
> > +	if (ns && atomic_dec_and_test(&ns->count))
> > +		schedule_work(&ns->free_nsproxy_work);
>=20
> What's wrong with using call_rcu()? The above will cause a workqueue
> thread to block for no good reason.

See comment to synchronize_rcu(). free_nsproxy() might sleep.
call_rcu() callback invocation might happen from either softirq or process
context, so we can't use it.


--=20
 Kirill A. Shutemov

--J2SCkAp4GZ/dPZZf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQBEPPAAoJEAd+omnVudOMZdAQALI4x2Muf9GD9zbr2SNDN32Z
HuRiCe6G+sHcym7sPGZ3cnFz4e34nIUK5+3oqGClC0fBlcdrgNaUJwgvnozERLen
qHKabvvYbOhEYqD322f6iv3ev3A4nEto5qA22T/OAXS9Ev58j1Y0cjnHYBtRiriA
WMBeTx5UTzZGoSwvMJikDPBlrH/YIyodPQRznXWNWPueMlR/CLyJTUDDTPBib0IJ
/8xU13bqkZZH+H1+irloYK9+ptzti/1u1NwgmxmRnb2pSQ/mSgzsrqz54NKjq5ui
2choRRVyPTTTJlXyMxjuOMgh3+7TGfx2h06Pc6JmbrCPp9rF7dcTHnuEAUoMMDgm
7xaIJPv2bWob5NLlVw+DIu518jjyhbvltyaQ7FCPHrC6xazwqWxWINZlUvy1r2la
FlGdBHHnyTr3mGS39UcNikh66Fqc596/gd9Rs0OPoNfIVfw7RVNEJnaG24v26rcr
KCtuMXoiCGh13Ui/w2awRgdfli7ySuF8bJ6U5vy2EPoymkRuwURNEMyLgiS3/APf
FZrkL1MDvTT6bViaI2BNoIkSVmTjAPmMYUjdIiY8PjD8usxOWWr9SkrVwpUqiheD
CjLT9qkKWfgJjvICHXzWCaSHdryLxocqtQ9PAZSYxDoYHJX+d/d89+yy/fBJgR/j
zen6V05UslR80CcpAKkY
=+6je
-----END PGP SIGNATURE-----

--J2SCkAp4GZ/dPZZf--

--===============6436946209527063367==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============6436946209527063367==--
