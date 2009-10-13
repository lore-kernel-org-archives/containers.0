From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: 2009 kernel summit preparation for 'containers end-game'
	discussion
Date: Tue, 13 Oct 2009 09:52:26 -0500
Message-ID: <20091013145226.GA6720@us.ibm.com>
References: <20091006155637.GA14761@us.ibm.com> <4AD37A3C.8020408@librato.com>
	<20091012190416.GA15143@us.ibm.com>
	<m18wfgjtaq.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m18wfgjtaq.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, cgroup-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> I am still slowly poking at the sysfs cleanups/changes.
> 
> For me the priorities are rougly:
> - bug fixes in the existing namespaces

Do you have a list of bugs you're looking at?

Do you mean true existing bugs, or also shortcomings?  (i.e.
sunrpc vs. netns, kernel interfaces not yet properly namespaced,
like autofs4 vs. pidns)

It might be worth keeping both a bug-list and shortcomings-list
under ckpt.wiki.kernel.org.

> - sysfs cleanups
> - sysfs for the network namespace ( and likely others )
> - a complete user namespace (I am tired of running everything as root).
> 
> I have a bunch of generally unrelated hotplug changes I am working on as
> well.
> 
> Now that the network namespace has stabalized I am hoping to have a bit more
> time for the others.

Cool.

thanks,
-serge
