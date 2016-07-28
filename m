From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [GIT PULL] binfmt_misc updates for 4.7+ merge window
Date: Wed, 27 Jul 2016 20:33:10 -0700
Message-ID: <CA+55aFwUDnS9POpBJysZurSBsWeyYbMF4qPKjD1sFygeFi7tTg__21134.8991761499$1469676804$gmane$org@mail.gmail.com>
References: <1469673106.3565.9.camel@HansenPartnership.com>
	<1469674670.3998.18.camel@perches.com>
	<CA+55aFzK_kNZBNU+Eq+VuuGttOTMP3xK1F9Lsxcff-wkzaNkyg@mail.gmail.com>
	<1469676065.3998.19.camel@perches.com>
	<CA+55aFz3+37s7eQ55kGbEEoGhMtvkAwYQ3szOSVrg3MKA+iWrg@mail.gmail.com>
	<CA+55aFxK7Xw2XsSJX6ErzTt+J-jywk26v4pP42rAs2=OkSfhFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CA+55aFxK7Xw2XsSJX6ErzTt+J-jywk26v4pP42rAs2=OkSfhFQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jul 27, 2016 at 8:31 PM, Linus Torvalds
<torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>
> I'd actually prefer to make "--git" the default, if you are inside a
> git repository. Because obviously the *actual* default is too hard to
> understand ;)

I'd also like to make the "-f" optional.

I constantly forget it, and curse it. It should be trivial to see "the
argument is a file that is tracked in git, so it clearly isn't the
name of a patch".

               Linus
