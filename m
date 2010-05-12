From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4][cr]: Define __f_setown_uid()
Date: Wed, 12 May 2010 12:54:26 -0500
Message-ID: <20100512175426.GA4839@hallyn.com>
References: <1273617500-13653-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1273617500-13653-3-git-send-email-sukadev@linux.vnet.ibm.com>
	<20100512080629.GB2636@us.ibm.com>
	<20100512084317.GA8842@us.ibm.com>
	<20100512165922.GA11144@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100512165922.GA11144-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> The process P1 that called fcntl(F_SETOWN) may have exited and hence
> may not in the checkpoint-image. So during restart, some other process
> will need to act for P1. Would requiring CAP_SETUID, like we do for
> restoring creds be an overkill ?

Yeah I think CAP_SETUID is overkill.  Yes, it's what would have been
needed to cause the condition originally, but the only real implication
is CAP_KILL.  And since the application might have originally run with
euid=1001 and suid=1002, done the fcntl, and then done
setresuid(1002,1002,1002), CAP_SETUID may not have originaly been
necessary (if I'm thinking straight).

In any case, CAP_KILL is what you can do with the result, so I think
that suffices.

-serge
