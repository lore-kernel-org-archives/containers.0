From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Escaping Containers
Date: Wed, 3 Aug 2011 16:49:51 -0500
Message-ID: <20110803214951.GB2778@sergelap>
References: <CAC6a4axVtNA-9DYUOkNHSBeu6o898LNnCqNL7hRv3MB4ftatkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAC6a4axVtNA-9DYUOkNHSBeu6o898LNnCqNL7hRv3MB4ftatkg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Prashanth Mohan <prashmohan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Prashanth Mohan (prashmohan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Hello,
> 
> I recently came across this blog posting
> (http://blog.bofh.it/debian/id_413) which details a mechanism to
> escape from Linux Containers. The posting seems to indicate that this
> is because sysfs does not support namespaces. Is this a problem that
> is being actively looked into? Is there a workaround for this and/or a
> permanent solution in the works?

For the latter, please read the whole blog post you cited.

For a workaround using Smack, see
   http://sourceforge.net/mailarchive/message.php?msg_id=27895058
from the lxc-users mailing list.

-serge
