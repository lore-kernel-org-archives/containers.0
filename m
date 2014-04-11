From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] cgroup: implement cgroup.subtree_populated for the
	default hierarchy
Date: Fri, 11 Apr 2014 17:00:51 +0800
Message-ID: <5347AF43.9000108@huawei.com>
References: <1397056052-2829-1-git-send-email-tj@kernel.org>
	<1397056052-2829-4-git-send-email-tj@kernel.org>
	<20140410030855.GA29658@mail.hallyn.com>
	<20140410130831.GA25308@htj.dyndns.org>
	<20140410140424.GA4481@sergelap>
	<20140410141957.GE25308@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140410141957.GE25308-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: rlove-L7G0xEPcOZbYtjvyW6yDsg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
List-Id: containers.vger.kernel.org

> Ah, you're right, cgroup_task_migrate() sets CGRP_RELEASABLE
> explicitly.  I was confused because put_css_set_locked() sets
> CGRP_RELEASABLE only if @taskexit is set.  Will drop that part from
> the description.
> 

"If the notify_on_release flag is enabled (1) in a cgroup, then
whenever the last task in the cgroup leaves (exits or attaches to
some other cgroup) and the last child cgroup of that cgroup
is removed, then the kernel runs the command specified by the contents
of the "release_agent" file"

says cgroups.txt. :)
