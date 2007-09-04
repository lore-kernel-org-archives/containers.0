From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [RFC] [PATCH 2/2] namespace enter: introduce
	sys_hijack (v3)
Date: Tue, 04 Sep 2007 12:06:18 -0700
Message-ID: <1188932778.28903.361.camel@localhost>
References: <20070829200420.GA4870@sergelap.austin.ibm.com>
	<20070829200515.GC4870@sergelap.austin.ibm.com>
	<6599ad830709030102w6b5084d4w4a8a9a654e421527@mail.gmail.com>
	<20070904125019.GA22410@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070904125019.GA22410-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2007-09-04 at 07:50 -0500, Serge E. Hallyn wrote:
> > What do you do if there are no processes in a particular container?
> 
> The nsproxy will have been released so you couldn't enter it anyway. 

Yeah, we'd need some kind of other object to keep the nsproxy around and
hold a reference to it.

But, it also begs other questions about how we define the namespace
boundaries vs. containers.  What if we have a normal container with
chroot'd process inside of it?  Two such processes will not share an
nsproxy because the chroot'd one has switched filesystem namespaces.

Who is to say that the "container" is represented by one process's
nsproxy more than another?

-- Dave
