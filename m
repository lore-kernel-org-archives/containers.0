From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [v10][PATCH 8/9] Define clone_with_pids() syscall
Date: Tue, 3 Nov 2009 09:46:52 +0100
Message-ID: <200911030946.52962.arnd@arndb.de>
References: <20091101204132.GA22116@us.ibm.com> <4AEF2077.5080107@librato.com>
	<20091103064454.GA22483@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091103064454.GA22483-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tuesday 03 November 2009, Sukadev Bhattiprolu wrote:
> 
> Oren Laadan [orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org] wrote:
> | 
> | > +   /*
> | > +    * TODO: If size of clone_args is not what the kernel expects, it
> | > +    *       could be that kernel is newer and has an extended structure.
> | > +    *       When that happens, this check needs to be smarter (and we
> | > +    *       need an additional copy_from_user()). For now, assume exact
> | > +    *       match.
> | > +    */
> | > +   if (kcs.clone_args_size != sizeof(kcs))
> | > +           return -EINVAL;
> | 
> | I wonder if this is a reason to move the clone_args_size outside the
> | structure and pass it as a regular argument ?  This will rid the
> | (futuristic) additional copy-from-user (in case it causes a concern
> | for clone performance ?)
> 
> Your idea makes sense to me. 
> 
> Roland, Peter Arnd: do you have any concerns with removing clone_args_size
> from the structure and making it a parameter ?

As I mentioned before when it came up the first time, I think that the
clone_args_size argument is completely bogus and unnecessary in the
presence of the flags word, but I agree that if we have it, it should
better be a separate argument.

	Arnd <><
