From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/9] cgroup: update error handling in cgroup_populate_dir()
Date: Thu, 11 Jul 2013 15:08:07 +0800
Message-ID: <51DE59D7.2000203@huawei.com>
References: <1372463145-4245-1-git-send-email-tj@kernel.org>
	<1372463145-4245-6-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1372463145-4245-6-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/6/29 7:45, Tejun Heo wrote:
> cgroup_populate_dir() didn't use to check whether the actual file
> creations were successful and could return success with only subset of
> the requested files created, which is nasty.
> 
> This patch udpates cgroup_populate_dir() so that it either succeeds
> with all files or fails with no file.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  kernel/cgroup.c | 24 ++++++++++++++++++------
>  1 file changed, 18 insertions(+), 6 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 254d54e..3475267 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -965,10 +965,12 @@ static void cgroup_rm_file(struct cgroup *cgrp, const struct cftype *cft)
>  static void cgroup_clear_dir(struct cgroup *cgrp, unsigned long subsys_mask)
>  {
>  	struct cgroup_subsys *ss;
> +	int i;
>  
> -	for_each_root_subsys(cgrp->root, ss) {
> +	for_each_subsys(ss, i) {

Why this change?

It even increases object size a bit:

   text    data     bss     dec     hex filename
  42524    5495    6336   54355    d453 kernel/cgroup.o.orig
   text    data     bss     dec     hex filename
  42636    5495    6336   54467    d4c3 kernel/cgroup.o

>  		struct cftype_set *set;
> -		if (!test_bit(ss->subsys_id, &subsys_mask))
> +
> +		if (!test_bit(i, &subsys_mask))
>  			continue;
>  		list_for_each_entry(set, &ss->cftsets, node)
>  			cgroup_addrm_files(cgrp, NULL, set->cfts, false);
> @@ -4171,19 +4173,26 @@ static struct cftype cgroup_base_files[] = {
>   * cgroup_populate_dir - create subsys files in a cgroup directory
>   * @cgrp: target cgroup
>   * @subsys_mask: mask of the subsystem ids whose files should be added
> + *
> + * On failure, no file is added.
>   */
>  static int cgroup_populate_dir(struct cgroup *cgrp, unsigned long subsys_mask)
>  {
>  	struct cgroup_subsys *ss;
> +	int i, ret = 0;
>  
>  	/* process cftsets of each subsystem */
> -	for_each_root_subsys(cgrp->root, ss) {
> +	for_each_subsys(ss, i) {

ditto
