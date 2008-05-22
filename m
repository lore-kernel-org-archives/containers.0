From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH -mm] remove node_ prefix_from ns subsystem
Date: Thu, 22 May 2008 01:10:53 -0700
Message-ID: <20080522011053.680f7f65.akpm@linux-foundation.org>
References: <48344409.9090903@fr.ibm.com>
	<20080521220657.12e8e8c9.akpm@linux-foundation.org>
	<6599ad830805220011u77313ed7s2c0c9d4a658133cc@mail.gmail.com>
	<20080522003213.d677ba30.akpm@linux-foundation.org>
	<48352277.4010703@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48352277.4010703-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 22 May 2008 09:36:23 +0200 Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:

> > What is the reason for making this change?
> 
> the 'node_' prefix really is superfluous and misleading. what's a node ?

For gawd's sake guys.  I've asked three times and now I'm getting
rhetorical questions for answers.  It's like drawing teeth.

Will someone please write a halfway decent description of this change? 
One which (at least) covers all the questions I've been asking?

What the change is, why it is being made, what the user-visible
presentation is, what the impact upon users is, why we think it won't
be a problem, etc?  The stuff which should have been right there from
day one, before the code change was even made?

Thanks.
