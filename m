From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [patch -mm 0/5] mqueue namespace
Date: Tue, 02 Oct 2007 05:01:25 -0600
Message-ID: <m1ejgdlr0a.fsf@ebiederm.dsl.xmission.com>
References: <20071002084608.149781400@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071002084608.149781400-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>> (Cedric Le Goater's
	message of "Tue, 02 Oct 2007 10:46:08 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

> Hello,
>
> Here's the mqueue namespace patchset. 
>
> If you're OK with it, I'll rebase on the next -mm which should contain
> the new CONFIG_NAMESPACES and send to andrew.

And before I forget.

At least until someone has done an audit and we are certain we
have gotten all of the user space interfaces.

We need to Kconfig the whole thing so support creating one of these
things depends on CONFIG_EXPERIMENTAL.

Once we have the code merged and have audited the merge result
we can remove the Kconfig and the CONFIG_EXPERIMENTAL bit.

Eric
