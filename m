From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: Thoughts on virtualizing task containers
Date: Mon, 1 Oct 2007 10:36:51 -0700
Message-ID: <6599ad830710011036w430557ccj8c56c46143bf68b0@mail.gmail.com>
References: <6599ad830708231718x7b63f993vdfef5b503668989d@mail.gmail.com>
	<20070827144025.GE4505@sergelap.austin.ibm.com>
	<6599ad830708281411x32fd0ca4u22464430d14bd990@mail.gmail.com>
	<20070911135925.GB15217@sergelap.austin.ibm.com>
	<6599ad830709252223r4b319d8dxa326aef8ff444606@mail.gmail.com>
	<20071001172447.GA20870@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071001172447.GA20870-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On 10/1/07, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> I'd advocate following this path.  Have you started any
> patches for this?

Started playing with it, but only really to see what breaks so far.

> > - the guest can only see subsystems in the same hierarchy, which
>
> same hierarchy as the virtualization cgroup subsystem, right?

Right.

>
> So then for subsystems which the guest did select, are there
> default values inherited from the parent cgroup, and restrictions based
> on those?  Or does the guest get to set any values it wants for those
> subsystems?

That's something that's going to need to be subsystem-specific, I
think. For something like cpusets, that already handles restricting a
child to be a subset of a parent, this should be automatic. There's
already talk of adding hierarchy to resource counters, which would
theoretically solve the problem for all resource counter users.

Paul
