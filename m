From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [GIT PULL] cgroup changes for v3.15-rc1
Date: Thu, 3 Apr 2014 12:01:23 -0700
Message-ID: <CA+55aFw2+VKojzoF2aDaruOMKHikTO8J0HeK9DoDLZr+HqTWbg@mail.gmail.com>
References: <20140403164911.GE24119@htj.dyndns.org>
	<CA+55aFy1dm_CoTv+tihQ+m54G3gR9siOngurHsuKf9W3k1sKKw@mail.gmail.com>
	<CA+55aFwBm202pchEH9A6vbJVdar9-T35pBF44cCt7FNjmno9sQ@mail.gmail.com>
	<CAOS58YMckmoCocguf9BC_Wxbn3D2Rx3MArhgozO9qCj4g=5aDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAOS58YMckmoCocguf9BC_Wxbn3D2Rx3MArhgozO9qCj4g=5aDw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

[ Extending the participants list a bit ]

On Thu, Apr 3, 2014 at 11:34 AM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On the road so sending from phone. Iirc the param is necessary to
> distinguishe when a new sb is created so that it can be put properly later.
> I think cgroup is leaking super ref now and li was planning to send a fix
> once things are merged.

So as far as I can tell, cgroup is fine, because the superblock itself
is properly refcounted by the mounting code. It's the magic hidden
"namespace" pointer that isn't properly refcounted, because that
stupid sucker is typeless and depends on the namespace kind (so to
drop a namespace pointer you need to pass in not just the pointer, but
also the right "KOBJ_NS_TYPE_xxx" type, which right now is always
KOBJ_NS_TYPE_NET).

Quite frankly, the whole "let's make the 'ns' pointer be a 'const void
*' and rely on people passing the right type along" is some seriously
crazy sh*t. Couldn't we force it to be a pointer to a union where the
first member is the type, so that

 (a) we don't use "const void *" that casts silently a bit too well to
*anything* (the "const" helps a bit, thankfully)

 (b) we don't have to pass both pointer and type along, we can just
pass the pointer, and the type can be looked up from it?

Hmm? It *looks* like the only thing that generates namespace pointers
right now is "net_namespace()", which just returns a "struct net *".
Could we just add that "type" as the first member of that struct, and
make the rule be (for any future namespaces) that the first member has
to be an "int type" field?

I might well have missed some other source that generates namespace
pointers, but it really looks like right now all those namespace()
things end up calling ->class->namespace(), and the only class that
then implements a namespace pointer function is networking and that
"net_namespace()". And I don't *think* that the networking code would
mind having that "int type" at the head of the "struct net" it uses.

The reason I'd like to have the type accessible from the pointer is
that then we *could* use that type to index into the namespace ops,
and grab reference counts etc. Instead of having that "const void *ns"
pointer that you can't do anything about, and have to expect that the
caller (that knows the type of it) will do the right thing wrt
refcounting etc.

Is there something I'm missing?

            Linus
