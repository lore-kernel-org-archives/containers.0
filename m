From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 1/2] memcg: dirty pages accounting and limiting
	infrastructure
Date: Mon, 1 Mar 2010 11:38:36 +0100
Message-ID: <20100301103836.GC2087__25581.4410433688$1267439963$gmane$org@linux>
References: <1267224751-6382-1-git-send-email-arighi@develer.com>
	<1267224751-6382-2-git-send-email-arighi@develer.com>
	<cc557aab1003010058i3a824f98l4cec173fac05911f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cc557aab1003010058i3a824f98l4cec173fac05911f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 01, 2010 at 10:58:35AM +0200, Kirill A. Shutemov wrote:
[snip]
> > +static u64 mem_cgroup_dirty_ratio_read(struct cgroup *cgrp, struct cft=
ype *cft)
> > +{
> > + =A0 =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> > +
> > + =A0 =A0 =A0 return get_dirty_param(memcg, MEM_CGROUP_DIRTY_RATIO);
> > +}
> > +
> > +static int
> > +mem_cgroup_dirty_ratio_write(struct cgroup *cgrp, struct cftype *cft, =
u64 val)
> > +{
> > + =A0 =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> > +
> > + =A0 =A0 =A0 if ((cgrp->parent =3D=3D NULL) || (val > 100))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> > +
> > + =A0 =A0 =A0 spin_lock(&memcg->reclaim_param_lock);
> > + =A0 =A0 =A0 memcg->dirty_ratio =3D val;
> > + =A0 =A0 =A0 memcg->dirty_bytes =3D 0;
> > + =A0 =A0 =A0 spin_unlock(&memcg->reclaim_param_lock);
> > +
> > + =A0 =A0 =A0 return 0;
> > +}
> > +
> > +static u64 mem_cgroup_dirty_bytes_read(struct cgroup *cgrp, struct cft=
ype *cft)
> > +{
> > + =A0 =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> > +
> > + =A0 =A0 =A0 return get_dirty_param(memcg, MEM_CGROUP_DIRTY_BYTES);
> > +}
> > +
> > +static int
> > +mem_cgroup_dirty_bytes_write(struct cgroup *cgrp, struct cftype *cft, =
u64 val)
> > +{
> > + =A0 =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> > +
> > + =A0 =A0 =A0 if (cgrp->parent =3D=3D NULL)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> > +
> > + =A0 =A0 =A0 spin_lock(&memcg->reclaim_param_lock);
> > + =A0 =A0 =A0 memcg->dirty_ratio =3D 0;
> > + =A0 =A0 =A0 memcg->dirty_bytes =3D val;
> > + =A0 =A0 =A0 spin_unlock(&memcg->reclaim_param_lock);
> > +
> > + =A0 =A0 =A0 return 0;
> > +}
> > +
> > +static u64
> > +mem_cgroup_dirty_background_ratio_read(struct cgroup *cgrp, struct cft=
ype *cft)
> > +{
> > + =A0 =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> > +
> > + =A0 =A0 =A0 return get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND=
_RATIO);
> > +}
> > +
> > +static int mem_cgroup_dirty_background_ratio_write(struct cgroup *cgrp,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cf=
type *cft, u64 val)
> > +{
> > + =A0 =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> > +
> > + =A0 =A0 =A0 if ((cgrp->parent =3D=3D NULL) || (val > 100))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> > +
> > + =A0 =A0 =A0 spin_lock(&memcg->reclaim_param_lock);
> > + =A0 =A0 =A0 memcg->dirty_background_ratio =3D val;
> > + =A0 =A0 =A0 memcg->dirty_background_bytes =3D 0;
> > + =A0 =A0 =A0 spin_unlock(&memcg->reclaim_param_lock);
> > +
> > + =A0 =A0 =A0 return 0;
> > +}
> > +
> > +static u64
> > +mem_cgroup_dirty_background_bytes_read(struct cgroup *cgrp, struct cft=
ype *cft)
> > +{
> > + =A0 =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> > +
> > + =A0 =A0 =A0 return get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND=
_BYTES);
> > +}
> > +
> > +static int mem_cgroup_dirty_background_bytes_write(struct cgroup *cgrp,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cf=
type *cft, u64 val)
> > +{
> > + =A0 =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> > +
> > + =A0 =A0 =A0 if (cgrp->parent =3D=3D NULL)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> > +
> > + =A0 =A0 =A0 spin_lock(&memcg->reclaim_param_lock);
> > + =A0 =A0 =A0 memcg->dirty_background_ratio =3D 0;
> > + =A0 =A0 =A0 memcg->dirty_background_bytes =3D val;
> > + =A0 =A0 =A0 spin_unlock(&memcg->reclaim_param_lock);
> > +
> > + =A0 =A0 =A0 return 0;
> > +}
> > +
> > =A0static struct cftype mem_cgroup_files[] =3D {
> > =A0 =A0 =A0 =A0{
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =3D "usage_in_bytes",
> > @@ -3518,6 +3785,26 @@ static struct cftype mem_cgroup_files[] =3D {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.write_u64 =3D mem_cgroup_swappiness_wri=
te,
> > =A0 =A0 =A0 =A0},
> > =A0 =A0 =A0 =A0{
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "dirty_ratio",
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D mem_cgroup_dirty_ratio_read,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D mem_cgroup_dirty_ratio_wri=
te,
> > + =A0 =A0 =A0 },
> > + =A0 =A0 =A0 {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "dirty_bytes",
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D mem_cgroup_dirty_bytes_read,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D mem_cgroup_dirty_bytes_wri=
te,
> > + =A0 =A0 =A0 },
> > + =A0 =A0 =A0 {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "dirty_background_ratio",
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D mem_cgroup_dirty_background=
_ratio_read,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D mem_cgroup_dirty_backgroun=
d_ratio_write,
> > + =A0 =A0 =A0 },
> > + =A0 =A0 =A0 {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "dirty_background_bytes",
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D mem_cgroup_dirty_background=
_bytes_read,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D mem_cgroup_dirty_backgroun=
d_bytes_write,
> > + =A0 =A0 =A0 },
> > + =A0 =A0 =A0 {
> =

> mem_cgroup_dirty_background_* functions are too similar to
> mem_cgroup_dirty_bytes_*. I think they should be combined
> like mem_cgroup_read() and mem_cgroup_write(). It will be
> cleaner.

Agreed.

Thanks,
-Andrea
