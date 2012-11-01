From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/8] cgroup: use cgroup_lock_live_group(parent) in
	cgroup_create()
Date: Thu, 1 Nov 2012 07:52:24 -0700
Message-ID: <CAOS58YM+kRtspVUzmnSmOmrDoNS_kF6KA02zWGxqH5FUcRWo1Q@mail.gmail.com>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-4-git-send-email-tj@kernel.org>
	<20121031155514.GD22809@dhcp22.suse.cz>
	<20121031170431.GF2945@htj.dyndns.org>
	<20121101091644.GA8533@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121101091644.GA8533-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey, Michal.

On Thu, Nov 1, 2012 at 2:16 AM, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org> wrote:
> I am not sure I understand. What does deactivate_super has to do with
> the above suggestion? cgroup_lock_live_group will take the cgroup_mutex
> on the success or frees the previously allocated&unused memory. The
> only thing I was suggesting is to do cgroup_lock_live_group first and
> allocate the cgroup only if it doesn't fail.

It complicates updates to the error exit path. You end up having to
update a lot more and it's not like grabbing lock first is
substantially better in any way, so why bother?

Thanks.

-- 
tejun
