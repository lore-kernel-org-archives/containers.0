From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Mon, 03 Nov 2008 09:48:29 -0800
Message-ID: <1225734509.12673.445.camel@nimitz>
References: <1225219047.12673.182.camel@nimitz>
	<m163n9y7yb.fsf@frodo.ebiederm.org> <1225411757.12673.383.camel@nimitz>
	<m1k5bpwj8j.fsf@frodo.ebiederm.org> <1225462902.12673.398.camel@nimitz>
	<m1r65wpjx2.fsf@frodo.ebiederm.org> <1225732999.12673.442.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1225732999.12673.442.camel@nimitz>
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
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2008-11-03 at 09:23 -0800, Dave Hansen wrote:
> The problem is that we can't possibly use refcounts (at least the ones
> we have today) alone.  For instance, with the pid namespace, we would
> have 1 ref for the 'init' process doing the sys_restore() call and then
> a possible second refcount for /proc.  Perhaps we could differentiate
> references to namespaces that instantiate objects inside the namespaces
> from purely references to the namespace *itself*.

By this, I mean something along the lines of 'mm_struct's mm_users vs.
mm_count.

-- Dave
