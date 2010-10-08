From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Fwd: Re: lxc-performance?
Date: Fri, 8 Oct 2010 11:41:22 -0500
Message-ID: <20101008164122.GA16891@hallyn.com>
References: <4CAED1CF.6050908@univ-fcomte.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4CAED1CF.6050908-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: MALATTAR <mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting MALATTAR (mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org):
> =

> =

> -------- Message original --------
> Sujet: 	Re: lxc-performance
> Date : 	Thu, 07 Oct 2010 16:56:05 +0200
> De : 	MALATTAR <mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
> Pour : 	MALATTAR <mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
> =

> =

> =

> Le 07/10/2010 16:43, MALATTAR a =E9crit :
> > ------------------------------------------------------------------------
> > 06.10.2010 23:41, MALATTAR ?????:
> >
> > >/  the container dora1, where i launch an instance of my IDS, does not=
 take
> > />/  more than 70 MB as memory even though the memory limit for it is m=
uch
> > />/  bigger than this value,
> > /
> > How do you measure memory usage?
> =

> by using the command:
> lxc-cgroup -n dora1 memory.usage_in_bytes
> >   What's in memory.max_usage_in_bytes of
> > the container's cgroup?
> executing the next command lxc-cgroup -n dora1 memory.max_usage_in_bytes
> gave me 70193152 bytes

Interesting - that's not the value you set in your intro email.

What does /var/lib/lxc/dora1/config have?
