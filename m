From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH O/4] Block I/O tracking
Date: Tue, 18 Mar 2008 19:16:24 +0900
Message-ID: <20080318191624.85ca135f.kamezawa.hiroyu__30558.3915360787$1205835312$gmane$org@jp.fujitsu.com>
References: <20080318.182251.93858044.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080318.182251.93858044.taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 18 Mar 2008 18:22:51 +0900 (JST)
Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:

>  # mount -t cgroup -o bio none /cgroup/bio
> 
> Then, you make new bio cgroups and put some processes in them.
> 
>  # mkdir /cgroup/bio/bgroup1
>  # mkdir /cgroup/bio/bgroup2
>  # echo 1234 /cgroup/bio/bgroup1/tasks
>  # echo 5678 /cgroup/bio/bgroup1/tasks
> 
> Now you check the ids of the bio cgroups which you just created.
> 
>  # cat /cgroup/bio/bgroup1/bio.id
>    1
>  # cat /cgroup/bio/bgroup2/bio.id
>    2
> 
> Finally, you can attach the cgroups to "ioband1" and assign them weights.
> 
>  # dmsetup message ioband1 0 type cgroup
>  # dmsetup message ioband1 0 attach 1
>  # dmsetup message ioband1 0 attach 2
>  # dmsetup message ioband1 0 weight 1:30
>  # dmsetup message ioband1 0 weight 2:60
> 
> You can find the manual of dm-ioband at
> http://people.valinux.co.jp/~ryov/dm-ioband/manual/index.html.
> But the user interface for the bio cgroup is temporal and it will be
> changed after the io_context support. 
> 
I'm grad if these some kinds of params rather than 'id' are also shown
under cgroup.

Thanks,
-Kame
