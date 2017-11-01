From: Christian Brauner <christian.brauner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 3/5] userns: Don't read extents twice in m_start
Date: Wed, 1 Nov 2017 15:01:45 +0100
Message-ID: <20171101140144.zwe7cq7iv2xudwp4@gmail.com>
References: <20171024220441.10235-1-christian.brauner@ubuntu.com>
	<20171024220441.10235-2-christian.brauner@ubuntu.com>
	<871sliubhj.fsf_-_@xmission.com> <87k1zaswu6.fsf_-_@xmission.com>
	<143adb61-fb8e-fc1b-396b-b18836e68766@suse.com>
	<87a806ntn0.fsf@xmission.com>
	<20171101130539.j5bxmhs2trqurrr2@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20171101130539.j5bxmhs2trqurrr2-Nxj+rRp3nVydTX5a5knrm8zTDFooKrT+cvkQGrU6aU0@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: tycho-E0fblnxP3wo@public.gmane.org, Nikolay Borisov <nborisov-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 01, 2017 at 02:05:39PM +0100, Peter Zijlstra wrote:
> On Wed, Nov 01, 2017 at 06:08:35AM -0500, Eric W. Biederman wrote:
> > Nikolay Borisov <nborisov-IBi9RG/b67k@public.gmane.org> writes:
> > 
> > > On  1.11.2017 01:48, Eric W. Biederman wrote:
> > >> 
> > >> This is important so reading /proc/<pid>/{uid_map,gid_map,projid_map} while
> > >> the map is being written does not do strange things.
> > >> 
> > >> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> > >> ---
> > >>  kernel/user_namespace.c | 6 ++++--
> > >>  1 file changed, 4 insertions(+), 2 deletions(-)
> > >> 
> > >> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> > >> index 563a2981d7c7..4f7e357ac1e2 100644
> > >> --- a/kernel/user_namespace.c
> > >> +++ b/kernel/user_namespace.c
> > >> @@ -683,11 +683,13 @@ static void *m_start(struct seq_file *seq, loff_t *ppos,
> > >>  		     struct uid_gid_map *map)
> > >>  {
> > >>  	loff_t pos = *ppos;
> > >> +	unsigned extents = map->nr_extents;
> > >> +	smp_rmb();
> > >
> > > Barriers need to be paired to work correctly as well as have explicit
> > > comments describing the pairing as per kernel coding style. Checkpatch
> > > will actually produce warning for that particular memory barrier.
> > 
> > So please look at the code and read the comment.
> 
> What comment, there isn't any, which is what he's complaining about.
> 
> > The fact the barrier was not in m_start earlier is strictly speaking a
> > bug.
> 
> Sure; doesn't excuse you for not writing sensible comments to go with
> it.
> 
> > In practice except for a very narrow window when this data is changing
> > the one time it can, this code does not matter at all.
> > 
> > As for checkpatch I have sympathy for it, checkpatch has a hard job,
> > but I won't listen to checkpatch when it is wrong.
> 
> No, undocumented barriers are a royal pain. Memory barriers should come
> with a comment that describes the desired ordering and points to the
> pairing barrier(s).

Tbf, this isn't solely Eric's fault. I'm to blame here too since I didn't
document the already existing smb_rmb()s and the new one I introduced when
writing the patches. I didn't know that there was a hard-set requirement to
document those. I also didn't see anything in the kernel coding style or the
memory barriers documentation (But it has been some time since I read those.).

> 
> Also, you probably want READ_ONCE() here and WRITE_ONCE() in
> map_write(), the compiler is free to do unordered byte loads/stores
> without it.
> 
> And finally, did you want to use smp_store_release() and
> smp_load_acquire() instead?

Maybe a stupid question but do you suspect this is a real problem in this case
since you're phrasing it as a question? Iirc, *_acquire() operations include
locking operations and might come with a greater performance impact then
smb_{rmb,wmb}(). Given that this is a very performance critical path we should
be sure.

> 
> Something like so perhaps?
> 
> ---
>  kernel/user_namespace.c | 73 ++++++++++++++++++++++++++++++-------------------
>  1 file changed, 45 insertions(+), 28 deletions(-)
> 
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index c490f1e4313b..f758911cabd5 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -25,8 +25,47 @@
>  #include <linux/fs_struct.h>
>  
>  static struct kmem_cache *user_ns_cachep __read_mostly;
> +
> +/*
> + * The userns_state_mutex serializes all writes to any given map.
> + *
> + * Any map is only ever written once.
> + *
> + * An id map fits within 1 cache line on most architectures.
> + */
>  static DEFINE_MUTEX(userns_state_mutex);
>  
> +/*
> + *
> + * There is a one time data dependency between reading the count of the extents
> + * and the values of the extents.  The desired behavior is to see the values of
> + * the extents that were written before the count of the extents.
> + *
> + * To achieve this smp_store_release() is used on guarantee the write order and
> + * smp_load_acquire() is guaranteed that we don't have weakly ordered
> + * architectures returning stale data.
> + */
> +static inline void map_store_extents(struct uid_gid_map *map, unsigned int extents)
> +{
> +	/*
> +	 * Ensure the map->extent[] stores happen-before we grow map->nr_extents
> +	 * to cover it. Matches the load_acquire in map_load_extents().
> +	 */
> +	smp_store_release(&map->nr_extents, extents);
> +}
> +
> +static inline unsigned int map_load_extents(struct uid_gid_map *map)
> +{
> +	/*
> +	 * Ensure the map->nr_extents load happens-before we try and access
> +	 * map->extent[], such that we guarantee the data is in fact there.
> +	 *
> +	 * Matches the store-relese in map_store_extents().
> +	 */
> +	return smp_load_acquire(&map->nr_extents);
> +}
> +
> +
>  static bool new_idmap_permitted(const struct file *file,
>  				struct user_namespace *ns, int cap_setid,
>  				struct uid_gid_map *map);
> @@ -206,8 +245,7 @@ static u32 map_id_range_down(struct uid_gid_map *map, u32 id, u32 count)
>  	id2 = id + count - 1;
>  
>  	/* Find the matching extent */
> -	extents = map->nr_extents;
> -	smp_rmb();
> +	extents = map_load_extents(map);
>  	for (idx = 0; idx < extents; idx++) {
>  		first = map->extent[idx].first;
>  		last = first + map->extent[idx].count - 1;
> @@ -230,8 +268,7 @@ static u32 map_id_down(struct uid_gid_map *map, u32 id)
>  	u32 first, last;
>  
>  	/* Find the matching extent */
> -	extents = map->nr_extents;
> -	smp_rmb();
> +	extents = map_load_extents(map);
>  	for (idx = 0; idx < extents; idx++) {
>  		first = map->extent[idx].first;
>  		last = first + map->extent[idx].count - 1;
> @@ -253,8 +290,7 @@ static u32 map_id_up(struct uid_gid_map *map, u32 id)
>  	u32 first, last;
>  
>  	/* Find the matching extent */
> -	extents = map->nr_extents;
> -	smp_rmb();
> +	extents = map_load_extents(map);
>  	for (idx = 0; idx < extents; idx++) {
>  		first = map->extent[idx].lower_first;
>  		last = first + map->extent[idx].count - 1;
> @@ -543,7 +579,7 @@ static void *m_start(struct seq_file *seq, loff_t *ppos,
>  	struct uid_gid_extent *extent = NULL;
>  	loff_t pos = *ppos;
>  
> -	if (pos < map->nr_extents)
> +	if (pos < map_load_extents(map))
>  		extent = &map->extent[pos];
>  
>  	return extent;
> @@ -652,25 +688,6 @@ static ssize_t map_write(struct file *file, const char __user *buf,
>  	char *kbuf = NULL, *pos, *next_line;
>  	ssize_t ret = -EINVAL;
>  
> -	/*
> -	 * The userns_state_mutex serializes all writes to any given map.
> -	 *
> -	 * Any map is only ever written once.
> -	 *
> -	 * An id map fits within 1 cache line on most architectures.
> -	 *
> -	 * On read nothing needs to be done unless you are on an
> -	 * architecture with a crazy cache coherency model like alpha.
> -	 *
> -	 * There is a one time data dependency between reading the
> -	 * count of the extents and the values of the extents.  The
> -	 * desired behavior is to see the values of the extents that
> -	 * were written before the count of the extents.
> -	 *
> -	 * To achieve this smp_wmb() is used on guarantee the write
> -	 * order and smp_rmb() is guaranteed that we don't have crazy
> -	 * architectures returning stale data.
> -	 */
>  	mutex_lock(&userns_state_mutex);
>  
>  	ret = -EPERM;
> @@ -790,8 +807,8 @@ static ssize_t map_write(struct file *file, const char __user *buf,
>  	/* Install the map */
>  	memcpy(map->extent, new_map.extent,
>  		new_map.nr_extents*sizeof(new_map.extent[0]));
> -	smp_wmb();
> -	map->nr_extents = new_map.nr_extents;
> +
> +	map_store_extents(map, new_map.nr_extents);
>  
>  	*ppos = count;
>  	ret = count;
