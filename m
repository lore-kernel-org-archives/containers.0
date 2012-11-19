From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] netcls_cgroup: implement hierarchy
	support
Date: Mon, 19 Nov 2012 11:01:05 -0800
Message-ID: <20121119190105.GL15971@htj.dyndns.org>
References: <1353123062-23193-1-git-send-email-tj@kernel.org>
	<50AA3B5E.3080701@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50AA3B5E.3080701-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Daniel.

On Mon, Nov 19, 2012 at 02:59:58PM +0100, Daniel Wagner wrote:
> Sorry to bring this up again: how should to root cgroup behave? If
> the ultimate goal to have only one single hierarchy then I would
> assume it is important that the semantic for all controllers are the
> same. As you pointed out the networking controllers are kind of a
> strange beast in the zoo of the cgroup controllers.  But still I
> would assume that all root controllers behave the same. memcg or
> cpu* are not expected to do any work in the root cgroup.

I think the implemented behavior is fine.  memcg or cpu* don't do
anything on root cgroup as it doesn't make much (or any) sense.  For
net_prio and cls, I don't see any reason to treat root cgroup
differently and how that would cause conflict when mounted together
with other controllers.  So, yeah, things seem okay to me.

Thanks.

-- 
tejun
