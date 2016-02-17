From: Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Make core_pattern support namespace
Date: Wed, 17 Feb 2016 21:54:08 +0100
Message-ID: <20160217205407.GD16757@mguzik>
References: <ce9a21e42a846150a2a482278f5b5a5e0ea27839.1454588184.git.zhaolei@cn.fujitsu.com>
	<20160216142608.GA16757@mguzik>
	<87k2m33xgj.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87k2m33xgj.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Feb 17, 2016 at 02:15:24PM -0600, Eric W. Biederman wrote:
> Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> > On Tue, Feb 16, 2016 at 07:33:39PM +0800, Zhao Lei wrote:
> >> For container based on namespace design, it is good to allow
> >> each container keeping their own coredump setting.
> >
> > Sorry if this is a false alarm, I don't have easy means to test it, but
> > is not this an immediate privilege escalation?
> 
> It is.  This is why we do not currently have a per namespace setting.
> 

Thanks for confimation.

> Solving the user mode helper problem is technically a fair amount of
> work, if not theoretically challenging.
> 

Well, I would say custom core_patterns without pipe support are still
better than none.

Say one would ensure a stable core_pattern (i.e. that it cannot be
modified as it is being parsed) and a restricted set of allowed
characters in the pattern (which would not include the pipe), validated
when one attempts to set the pattern.

Does this sound acceptable? If so, and there are no counter ideas from
Lei, I can get around to that.

-- 
Mateusz Guzik
