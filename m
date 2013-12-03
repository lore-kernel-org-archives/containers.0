From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 07/12] cgroup: unify cgroup_write_X64() and
	cgroup_write_string()
Date: Tue, 3 Dec 2013 15:41:55 -0500
Message-ID: <20131203204155.GL8277@htj.dyndns.org>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
	<1385595759-17656-8-git-send-email-tj@kernel.org>
	<20131128111818.GG2761@dhcp22.suse.cz>
	<20131129200525.GC21755@mtj.dyndns.org>
	<20131202095401.GA18838@dhcp22.suse.cz>
	<20131202133059.GA3626@htj.dyndns.org>
	<20131202141242.GD18838@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131202141242.GD18838-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Michal.

On Mon, Dec 02, 2013 at 03:12:42PM +0100, Michal Hocko wrote:
> I really do not want to add more hacks just to make this use case work.
> There are some proposals for more systematic implementation (memory
> reserves for oom killer etc.) but that won't interfere with the cgroup
> core.
> This one just looks trivial so I was thinking whether we can keep the
> !allocating write as before. It is nothing I would insist on, though. So
> I will leave the decision on you.

So, I'm just gonna commit the patches as-is because I can't really see
how this is anything which can work in any reasonable way.  As it
currently stands, the userland wouldn't even be able to read any knob.
Wouldn't it at least need to do that?  Actually, the answer to that
question doesn't even matter because "no" would mean that the OOM
notification, however it's done, can't depend on the userland being
able to read *any* knob, which in turn is likely to constrain and
distort the notification mechanism itself.  These things are all
connected and this type of bad decisions propagates through the whole
stack.

In case this *really* is necessary, let's please do it in a separate
patch with rationale and detailed explanation of actual usage.

Thanks.

-- 
tejun
