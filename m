From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 0/17] Make the network stack usable by userns root
Date: Sun, 18 Nov 2012 22:26:01 -0500 (EST)
Message-ID: <20121118.222601.1683927229305655885.davem__21881.5611828633$1353295585$gmane$org@davemloft.net>
References: <87d2zd8zwn.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d2zd8zwn.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Date: Fri, 16 Nov 2012 05:01:44 -0800

> 
> In a secondary user namespace the root user only has CAP_NET_ADMIN,
> CAP_NET_RAW and CAP_NET_BIND_SERVICE with respect to the secondary user
> namespace.  The test "capable(CAP_NET_ADMIN)" tests for capabilities in
> the initial user namespace.
> 
> The following set of patches goes through the networking stack.  First
> pushing the capable(CAP_NET_ADMIN) admin calls down farther in the stack
> so individual instances can be changed.  Then where I have I it appears
> safe I have relaxed the permission checks.
> 
> The code is available in git from:
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git netns-v73
> 
> The netns-v73 branch is against v3.7-rc3 and merges cleanly with net-next.
> 
> In my user namespace tree I am working to allow unprivileged users to
> create user namespace, and to allow the user namespace root able to
> create network namespaces.  Making these patches really about allowing
> unprivileged users able to use the networking stack (not that they will
> be able to talk to anyone).
> 
> David I have some small dependencies on the first two patches of this
> series in my later user namespace work.  So after these changes have
> been reviewed if you can pull my netns-v73 branch (which is just these
> patches) into net-next that will help me avoid unnecessary conflicts.

There were merge issues so I applied the patches and sorted the
conflicts out one-by-one.

I hope this doesn't cause major problems.
