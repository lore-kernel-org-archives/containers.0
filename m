From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [RFC PATCH 0/9] Add container support for cgroup
Date: Mon, 17 Dec 2012 07:16:08 -0600
Message-ID: <20121217131608.GA5163__22673.1282812127$1355750210$gmane$org@sergelap>
References: <1355726615-15224-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1355726615-15224-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> Right now,if we mount cgroup in the container,we will get
> host's cgroup informations and even we can change host's
> cgroup in container.
> 
> So the resource controller of the container will lose
> effectiveness.
> 
> This patchset try to add contianer support for cgroup.
> the main idea is allocateing cgroup super-block for each
> cgroup mounted in different pid namespace.
> 
> The top cgroup of container will share css with host.
> When the cgroup being mounted in contianer,the tasks in
> this container will be attached to this new mounted
> hierarchy's top cgroup, And when unmounting cgroup in
> container,these tasks will be attached back to host's cgroup.
> 
> Since the container can change the shared css through it's
> cgroup subsystem files. patch 7/8 disable the write permission
> of container's top cgroup files. In my TODO list, container
> will have it's own css, this problem will disappear.
> 
> 
> This patchset is sent as RFC,any comments are welcome.
> Maybe this isn't the best solution, if you have better
> solution,Please let me know.

Sounds very interesting, thanks.  I'm out (and mostly AFK) but
will take a look on wed or thu.

-serge
