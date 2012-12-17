From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC PATCH 0/9] Add container support for cgroup
Date: Mon, 17 Dec 2012 15:56:23 -0800
Message-ID: <20121217235623.GB10220@mtj.dyndns.org>
References: <1355726615-15224-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20121217234816.GA10220@mtj.dyndns.org>
	<87obhsgrq7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87obhsgrq7.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Eric.

On Mon, Dec 17, 2012 at 03:54:08PM -0800, Eric W. Biederman wrote:
> Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:
> 
> > So, I'm *highly* unlikely to accept any patches which try to add
> > namespace support directly to cgroup in any form unless someone can
> > definitively show me this can't be done using FUSE or other userland
> > solutions.
> 
> FUSE doesn't work in user namespaces.  Nor have I seen any interest by
> FUSE developers to even comment on patches doing anything of the sort.

Why doesn't it?  Is there any fundamental technical reason it can't
work or is it just because nobody is working on it?

> So at the moment FUSE is not useful as even a rhetorical point. FUSE is
> DOA.

I don't really care how it gets done but the barrier to adding NS
support to cgroupfs proper is gonna be very high.

Thanks.

-- 
tejun
