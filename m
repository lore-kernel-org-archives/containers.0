From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [Lsf-pc] Authentication Contexts for network file systems and
	Containers was Re: [LSF/MM ATTEND] FS jitter testing, network caching,
	Lustre, cluster filesystems.
Date: Mon, 16 Jan 2017 13:03:25 -0800
Message-ID: <1484600605.2540.73.camel@HansenPartnership.com>
References: <D863EDBD-277B-4CC3-854F-D57FF4501542@linuxhacker.ru>
	<20170116171708.GC2953@fieldses.org>
	<409e0dcb-0e6e-b37a-d8d1-039f92d466ac@auristor.com>
	<B992125F-7D3B-460A-9A6A-ACFBEA2607A8@oracle.com>
	<1484588818.2540.43.camel@HansenPartnership.com>
	<c663a698-7116-76ac-25ee-c0ea35971a05@auristor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <c663a698-7116-76ac-25ee-c0ea35971a05-hRzEac23uH1Wk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jeffrey Altman <jaltman-hRzEac23uH1Wk0Htik3J/w@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lsf-pc-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2017-01-16 at 15:39 -0500, Jeffrey Altman wrote:
> 	Error verifying signature: parse error
> --------------ms000508080908050405010401
> Content-Type: multipart/mixed;
>  boundary="------------049F6401F78BABEBFB8F74AC"
> 
> This is a multi-part message in MIME format.
> --------------049F6401F78BABEBFB8F74AC
> Content-Type: text/plain; charset=utf-8
> Content-Transfer-Encoding: quoted-printable
> 
> On 1/16/2017 12:46 PM, James Bottomley wrote:
> > 
> > For identity, doesn't the UTS namespace do this?  If not, what is
> > missing?
> > =20
> > James
> 
> James,
> 
> Thanks for posing the question.
> 
> Unless I'm missing something, the UTS namespace permits an alternate
> 'hostname' and NIS 'domainname' to be specified for local visibility 
> to the processes running in the container.
> 
> For an /afs network file system client (kafs, OpenAFS or AuriStorFS) 
> the kernel module must be able to associate each process with an
> authentication context.  The AFS family of file systems have 
> implemented this binding as part of its Process Authentication Group 
> (PAG) concept. A PAG is a set of processes that share an 
> authentication context.   The authentication context includes:
[...]

OK, so snipping all the details: it's a per process property and
inherited, I don't even see that it needs anything container specific. 
 The pid namespace should be sufficient to keep any potential security
leaks contained and the inheritance model should just work with
containers.

> While a file system can internally create an association between an
> authentication content with a file descriptor once it is created and
> with pages for write-back, I believe there would be benefit from a 
> more generic method of tracking authentication contexts in file
> descriptors and pages.  In particular would be better defined 
> behavior when a file has been opened for "write" from processes 
> associated with more than one authentication context.

As long as an "authentication" becomes a property of a file descriptor
(like a token), then I don't see any container problems: fds are
namespace blind, so they can be passed between containers and your
authorizations would go with them.  If you need to go back to a process
as part of the authorization, then there would be problems because
processes are namespaced.

> For example, the problems that AFS is currently experiencing with
> systemd. A good description of problem by Jonathan Billings can be
> found at
> 
> 
> https://docs.google.com/document/d/1P27fP1uj-C8QdxDKMKtI-Qh00c5_9zJa4
> YHjn=pB6ODM/pub

This is giving me "Sorry, the file you have requested does not exist."

James
