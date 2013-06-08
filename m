From: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Subject: Re: Requirements for CAP_SYS_ADMIN on setns() ?
Date: Sat, 08 Jun 2013 14:54:09 -0500
Message-ID: <1370721249.2776.87@driftwood>
References: <20130606100149.GG30217@redhat.com>
	<20130606134802.GA2930@ac100> <87txlb8atb.fsf@xmission.com>
	<20130606164428.GA4687@austin.hallyn.com> <87bo7j6r80.fsf@xmission.com>
	<20130607093459.GB10742@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="Flowed"; DelSp="Yes"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130607093459.GB10742-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (from berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
	on Fri Jun  7 04:34:59 2013)
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Waaaay behind on my email...

On 06/07/2013 04:34:59 AM, Daniel P. Berrange wrote:
> On Thu, Jun 06, 2013 at 11:15:11AM -0700, Eric W. Biederman wrote:
> > "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> > setns requires CAP_SYS_ADMIN because changing the namespaces for  
> your
> > children can result in tricking a suid root application and thus  
> lead
> > to privilege escalation.
> 
> Yep, ok I see that from the example shown earlier in the thread.
> 
> > If you run setns inside a user namespace that you control the  
> privilege
> > escalation is not possible and so setns is allowed.
> 
> What are the privilege requirements for being able to call setns() on
> a user namespace FD ?
> 
> Thinking some more, if there was a setpidns(pid_t containerpid)  
> syscall
> which unconditionally joined the caller to all namespaces associated  
> with
> the target pid, then you'd not have the security risk described,  
> right ?

Sounds like you want a reparent_to_init() that works for a container's  
init.

Rob
