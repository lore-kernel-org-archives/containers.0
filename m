From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH linux-next] cgroup: fix warning in css_from_id()
Date: Wed, 28 Aug 2013 08:26:15 -0400
Message-ID: <20130828122615.GB18348@mtj.dyndns.org>
References: <1377691485-26013-1-git-send-email-vincent.stehle@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1377691485-26013-1-git-send-email-vincent.stehle-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vincent =?iso-8859-1?Q?Stehl=E9?= <vincent.stehle-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Aug 28, 2013 at 02:04:45PM +0200, Vincent Stehl=E9 wrote:
> Commit ca8bdcaff0d77990fb69e0f946018c96a70851cc changes cgroup_css() seco=
nd
> argument type; update css_from_id() accordingly.
> =

> This fixes the following compilation warning:
> =

>   kernel/cgroup.c: In function 'css_from_id':
>   kernel/cgroup.c:5723:3: warning: passing argument 2 of 'cgroup_css' mak=
es pointer from integer without a cast [enabled by default]
>   kernel/cgroup.c:237:36: note: expected 'struct cgroup_subsys *' but arg=
ument is of type 'int'
> =

> Signed-off-by: Vincent Stehl=E9 <vincent.stehle-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Fixed up yesterday in cgroup/for-3.12 branch.  Today's next should be
okay.

Thanks.

-- =

tejun
