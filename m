From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Wed, 26 Oct 2016 12:43:18 +0100
Message-ID: <28032.1477482198__34460.1229568527$1477482255$gmane$org@warthog.procyon.org.uk>
References: <17576.1477412418@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <17576.1477412418-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Content-ID: <28031.1477482198.1-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

I think it might help if I lay out the current state of play:

Keys and keyrings can be accessed through a number of mechanisms:

 (1) Direct key lookup by serial number.

     The serial number set is global, so any key can potentially be looked up
     directly with the condition:

     (A) The key must grant the appropriate permission to the caller for the
     	 operation being proposed.

 (2) Direct keyring lookup by description (name).

     The keyring name set is global, so potentially any keyring could be set
     to the caller's session keyring.  However, there are two noteworthy
     conditions:

     (A) The keyring's uid must have a mapping in the current user namespace.

     (B) The keyring must grant SEARCH permission to the caller.

 (3) Process-subscribed keyrings.

     A process has a number of keyring subscriptions (the session, process and
     thread keyrings).  These are accessed by special negative serial numbers,
     macroised as KEY_SPEC_{THREAD,PROCESS,SESSION}_KEYRING.

     If a key can be reached via one of these keyrings then it is classed as
     being 'possessed' and the possession permissions grant is added to the
     user/group/other grant, with the following conditions:

     (A) The keyring being accessed must grant SEARCH to look inside it or
     	 some other appropriate permission to deal with the keyring itself.

 (4) User-subscribed keyrings.

     A user ID also has a couple of subscriptions (user and user-session
     keyrings).  These are accessed by KEY_SPEC_{USER,USER_SESSION}_KEYRING.

 (5) Group-subscribed keyrings.

     Linus wanted this for completeness, but it was never implemented.
     KEY_SPEC_GROUP_KEYRING is defined for this.

 (6) Search in directly-looked up keyring.

     A keyring can be looked up directly as per (1) and then searched inside
     for a key by description or some other identifier.  The conditions are:

     (A) The keyring must grant SEARCH permission, as must any subordinate
     	 keyrings that need to be searched.

     (B) The target key must grant SEARCH permission.

     Note that each key considered will *only* be considered possessed if the
     starting keyring is determined to be possessed.  Whilst this will give
     some false negatives, it massively reduces computation time.

 (7) Search in session-, process- and thread-keyrings.

     As (4), but the starting keyring is definitely possessed.

     Further, the user-session keyring is used in place of the session keyring
     if the caller doesn't have a session keyring, and the keys in there are
     counted as possessed.

 (8) Search in the user-keyring and user-session keyring.

     As (4).  These two keyrings are treated no differently from any other
     keyring.  pam_keyinit, however, places a link to the user-keyring in any
     session-keyring it creates, thereby making it possessed.

     [I wish I hadn't made user- and user-session keyrings as they're kind of
      difficult to get right.  It would've been better not to automatically
      fall back to the user-session keyring, I think.]

 (9) Lookup in the persistent keyring register.

     The persistent register is per-user_namespace.  You can ask for the
     persistent keyring for any UID, but:

     (A) That UID must be within your user_namespace

     (B) The UID must match your process UID or EUID - or you must have
     	 CAP_SETUID.

     Further, no matter which one you ask for:

     (C) The persistent keyring must grant you LINK permission.

     Note that persistent keyrings only grant VIEW and READ to user and grant
     everything bar SETATTR to possessed.

(10) /proc/keys.

     This shows all keys to which you have at least one permit, with the
     condition:

     (A) The keyring's uid must have a mapping in the current user namespace.

(11) Request-key upcall specials.

     If a process was created by request_key() as an upcall, then three
     additional keys become available:

       (i) A new session keyring concocted by request_key() holding the
     	   authorisation key that allows the protection mechanisms to be
     	   bypassed by keyctl_instantiate() and friends for the key being
     	   constructed.

      (ii) The currently active authorisation key.  If one is set by
     	   keyctl_assume_authority(), then this permits the upcall to search
     	   the subscribed keyrings of the original calling process as if they
     	   were its own.  This would allow it, say, to retrieve the caller's
     	   Kerberos TGT and to request a ticket with which to instantiate a
     	   key.

     (iii) The keyring passed to request_key_and_link() as the destination.
     	   This has no special permissions.  It's treated like any other
     	   non-possessed keyring unless the upcall program links it to such as
     	   its session keyring or it is accessible through the authorisation
     	   key.  Note that it's only available if an authorisation key is in
     	   use.


So:

 (*) Key serial numbers are global, though randomly generated and hopefully
     unpredictable.

 (*) Normal keys and keyrings are created by default with zero OTHER and GROUP
     permits, minimal USER permits and full POSSESSOR permits.

     Special keys may get a different balance of USER and POSSESSOR permits,
     but OTHER and GROUP are always initially zero.

 (*) You cannot access an ordinary key outside of your namespace unless:

     (A) it belongs to the founding user, you are that user within the
     	 namespace and it grants USER permits, or

     (B) it grants OTHER permits, or

     (C) it's attached to a subscribed keyring and it grants POSSESSOR
     	 permits, including SEARCH, or

     (D) you're trying to unlink it from a keyring you have WRITE access to
     	 (and then all you can do is unlink it).

 (*) You cannot find a session keyring that's owned by a UID that's outside of
     your namespace in order to join it.  Trying to do so gives a new session
     keyring of the same name.

 (*) Session-, process- and thread-keyrings are carried across clone() (as
     appropriate) or unshare(), even if CLONE_NEWUSER is set.

 (*) You cannot see in /proc/keys any keys owned by the founding user of a new
     namespace, though you can create and manipulate keys accessible through
     the carried over keyrings or accessible by ID.

     This is may need fixing - you should be able to see any key that you can
     access.

 (*) The installation of user and user-session keyrings in a user_struct
     waives the SEARCH permit that's a requirement for when
     keyctl_join_session_keyring() does a by-name search.


Thoughts:

 (*) request_key() upcalls are not namespaced.  It's not clear how this should
     be done, since the upcall might depend on network namespace or filesystem
     namespace, for example.

 (*) Possibly user and user-session keyrings could be kept in the persistent
     keyring rather than the user_struct, though there's a problem with the
     persistent keyring potentially timing out.

David
