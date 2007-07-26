From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/15] Helpers to obtain pid numbers
Date: Thu, 26 Jul 2007 12:03:01 -0700
Message-ID: <1185476582.18414.114.camel@localhost>
References: <46A8B37B.6050108@openvz.org>  <46A8B4D6.1080301@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46A8B4D6.1080301-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2007-07-26 at 18:51 +0400, Pavel Emelyanov wrote:
> 
> + * pid_nr()    : global id, i.e. the id seen from the init namespace;
> + * pid_vnr()   : virtual id, i.e. the id seen from the namespace this pid
> + *               belongs to. this only makes sence when called in the
> + *               context of the task that belongs to the same namespace; 

Can we give these some better names?  I think "virtual" is pretty bad,
especially if you consider the multiple level of pid namespaces that we
might have some day.  Processes can belong to multiple pid namespaces,
and thus have multiple "virtual" ids.

Even though it will make the names longer, I think we need something in
the names to say that "pid_nr()" is the top-level, global, init_pid_ns
number.  "pid_vnr()" is the pid for the lowest pid namespace in the
hierarchy.  Suka called this an "active pid namespace" because that is
where the task actively interacts with its peers.  But, I'm open to
other suggestions, too.

When writing code, people are going to need to know which one to use:
pid_nr() or pid_vnr().  We can document the functions, but the names
will help much more than any documentation.


-- Dave
